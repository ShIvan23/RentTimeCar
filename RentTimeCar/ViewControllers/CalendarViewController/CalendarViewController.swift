//
//  CalendarViewController.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 09.09.2025.
//

import FSCalendar
import UIKit

final class CalendarViewController: UIViewController {
    // MARK: - UI (always present)

    private let calendar = FSCalendar()
    private let selectButton = MainButton(title: "Выбрать")
    private let shimmerView = ShimmerView()

    // MARK: - UI (time sliders, only used when showTimeSliders = true)

    private let sliderScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        sv.alwaysBounceVertical = false
        sv.delaysContentTouches = false
        return sv
    }()

    private let rangeHeaderLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryTextColor
        l.textAlignment = .center
        return l
    }()

    private let startSliderRow = UIView()
    private let endSliderRow = UIView()

    private let startTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "НАЧАЛО"
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = .secondaryTextColor
        return l
    }()
    private let startSlider: UISlider = {
        let s = UISlider()
        s.minimumValue = 0
        s.maximumValue = 1410
        s.minimumTrackTintColor = .white
        s.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.2)
        return s
    }()

    private let endTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "КОНЕЦ"
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = .secondaryTextColor
        return l
    }()
    private let endSlider: UISlider = {
        let s = UISlider()
        s.minimumValue = 0
        s.maximumValue = 1410
        s.minimumTrackTintColor = .white
        s.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.2)
        return s
    }()

    private let durationLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryTextColor
        return l
    }()

    private let priceContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = .secondaryBackground
        v.layer.cornerRadius = 12
        v.isHidden = true
        return v
    }()
    private let priceFormulaLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryTextColor
        l.textAlignment = .center
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.7
        return l
    }()
    private let priceTotalLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17, weight: .semibold)
        l.textColor = .whiteTextColor
        l.textAlignment = .center
        return l
    }()

    // MARK: - Private Properties

    private let autoId: String?
    private let coordinator: ICoordinator
    private let showTimeSliders: Bool
    private let calendarTitle: String?
    private let dailyPrice: Int?
    private var firstDate: Date?
    private var lastDate: Date?
    private var datesRange = [Date]() {
        didSet {
            guard showTimeSliders else { return }
            updateRangeHeader()
            updateDurationLabel()
            updatePriceContainer()
        }
    }
    private var selectedStartMinutes: Int
    private var selectedEndMinutes: Int
    private let filterService = FilterService.shared
    private let rentApiFacade: IRentApiFacade = RentApiFacade()
    /// "dd.MM.yyyy" → isFree
    private var calendarData: [String: Bool] = [:]
    /// Ключи загруженных месяцев в формате "MM.yyyy"
    private var loadedMonths: Set<String> = []

    private static let monthKeyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MM.yyyy"
        return f
    }()

    private static let calendarDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd.MM.yyyy"
        return f
    }()

    private static let priceFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = "\u{202F}"
        f.maximumFractionDigits = 0
        return f
    }()

    private static let apiDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd.MM.yyyy HH:mm:ss"
        f.timeZone = TimeZone(identifier: "UTC")
        return f
    }()

    // MARK: - Init

    init(
        autoId: String? = nil,
        coordinator: ICoordinator,
        showTimeSliders: Bool = false,
        calendarTitle: String? = nil,
        dailyPrice: Int? = nil
    ) {
        self.autoId = autoId
        self.coordinator = coordinator
        self.showTimeSliders = showTimeSliders
        self.calendarTitle = calendarTitle
        self.dailyPrice = dailyPrice
        self.selectedStartMinutes = FilterService.shared.selectedStartMinutes
        self.selectedEndMinutes = FilterService.shared.selectedEndMinutes
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        if let autoId {
            fetchAutoCalendar(autoId: autoId)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        performLayout()
    }

    // MARK: - Private Methods

    private func setupView() {
        view.backgroundColor = .mainBackground
        if let calendarTitle { title = calendarTitle }
        setupCalendar()
        if showTimeSliders {
            priceContainerView.addSubviews([priceFormulaLabel, priceTotalLabel])
            startSliderRow.addSubviews([startTitleLabel, startSlider])
            endSliderRow.addSubviews([endTitleLabel, endSlider])
            // Calendar and controls all go inside the scroll view so the calendar
            // always gets its full height and controls scroll on small screens.
            sliderScrollView.addSubviews([
                rangeHeaderLabel,
                shimmerView,
                calendar,
                startSliderRow,
                endSliderRow,
                durationLabel,
                priceContainerView
            ])
            view.addSubviews([sliderScrollView, selectButton])
            setupTimeSliders()
        } else {
            view.addSubviews([shimmerView, calendar, selectButton])
        }
        setupButtonAction()
        if autoId != nil {
            calendar.isHidden = true
            shimmerView.startAnimating()
        } else {
            shimmerView.isHidden = true
        }
    }

    private func setupCalendar() {
        calendar.delegate = self
        calendar.dataSource = self
        calendar.today = nil
        calendar.allowsMultipleSelection = true
        calendar.placeholderType = .none
        calendar.firstWeekday = 2
        calendar.locale = Locale(identifier: "ru_RU")
        calendar.appearance.headerDateFormat = "LLLL yyyy"
        calendar.appearance.titleDefaultColor = .whiteTextColor
        calendar.appearance.headerTitleColor = .whiteTextColor
        calendar.appearance.weekdayTextColor = .whiteTextColor
        calendar.clipsToBounds = true
        filterService.selectedDates.forEach {
            calendar.select($0)
        }
        datesRange = filterService.selectedDates
        firstDate = filterService.selectedDates.first
        lastDate = filterService.selectedDates.last
        updateClearButton()
    }

    private func setupTimeSliders() {
        startSlider.value = Float(selectedStartMinutes)
        endSlider.value = Float(selectedEndMinutes)
        startSlider.addTarget(self, action: #selector(startSliderChanged), for: .valueChanged)
        endSlider.addTarget(self, action: #selector(endSliderChanged), for: .valueChanged)
        updateSliderThumbs()
        updateRangeHeader()
        updateDurationLabel()
        updatePriceContainer()
    }

    private func setupButtonAction() {
        selectButton.action = { [weak self] in
            guard let self else { return }
            sendSelectedDates()
            navigationController?.popViewController(animated: true)
        }
    }

    private func updateClearButton() {
        navigationItem.rightBarButtonItem = datesRange.isEmpty ? nil : clearBarButton
    }

    private lazy var clearBarButton: UIBarButtonItem = {
        UIBarButtonItem(
            title: "Сбросить",
            style: .plain,
            target: self,
            action: #selector(clearDates)
        )
    }()

    @objc private func clearDates() {
        calendar.selectedDates.forEach { calendar.deselect($0) }
        firstDate = nil
        lastDate = nil
        datesRange = []
        updateClearButton()
    }

    private func sendSelectedDates() {
        filterService.setSelectedDates(datesRange)
        if showTimeSliders {
            filterService.setSelectedTime(startMinutes: selectedStartMinutes, endMinutes: selectedEndMinutes)
        }
    }

    // MARK: - Time Slider Methods

    @objc private func startSliderChanged(_ slider: UISlider) {
        let step: Float = 30
        slider.value = round(slider.value / step) * step
        selectedStartMinutes = Int(slider.value)
        updateSliderThumbs()
        updateRangeHeader()
        updateDurationLabel()
        updatePriceContainer()
    }

    @objc private func endSliderChanged(_ slider: UISlider) {
        let step: Float = 30
        slider.value = round(slider.value / step) * step
        selectedEndMinutes = Int(slider.value)
        updateSliderThumbs()
        updateRangeHeader()
        updateDurationLabel()
        updatePriceContainer()
    }

    private func updateSliderThumbs() {
        let startImg = makeThumbImage(for: selectedStartMinutes)
        startSlider.setThumbImage(startImg, for: .normal)
        startSlider.setThumbImage(startImg, for: .highlighted)
        let endImg = makeThumbImage(for: selectedEndMinutes)
        endSlider.setThumbImage(endImg, for: .normal)
        endSlider.setThumbImage(endImg, for: .highlighted)
    }

    private func makeThumbImage(for minutes: Int) -> UIImage {
        let text = minutesToTimeString(minutes)
        let size = CGSize(width: 62, height: 28)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            UIColor.white.setFill()
            UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 14).fill()
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
                .foregroundColor: UIColor.black
            ]
            let str = NSAttributedString(string: text, attributes: attrs)
            let strSize = str.size()
            str.draw(at: CGPoint(
                x: (size.width - strSize.width) / 2,
                y: (size.height - strSize.height) / 2
            ))
        }
    }

    private func minutesToTimeString(_ minutes: Int) -> String {
        String(format: "%02d:%02d", minutes / 60, minutes % 60)
    }

    private func updateRangeHeader() {
        guard showTimeSliders else { return }
        let startStr = minutesToTimeString(selectedStartMinutes)
        let endStr = minutesToTimeString(selectedEndMinutes)
        if let first = datesRange.first, let last = datesRange.last {
            let fmt = DateFormatter()
            fmt.dateFormat = "EE, d MMM."
            fmt.locale = Locale(identifier: "ru_RU")
            rangeHeaderLabel.text = "\(fmt.string(from: first)) \(startStr) – \(fmt.string(from: last)) \(endStr)"
        } else {
            rangeHeaderLabel.text = "\(startStr) – \(endStr)"
        }
        view.setNeedsLayout()
    }

    private func updateDurationLabel() {
        guard showTimeSliders else { return }

        // Нет выбранных дат
        guard !datesRange.isEmpty else {
            durationLabel.text = "СРОК: —"
            view.setNeedsLayout()
            return
        }

        let dayCount = max(0, datesRange.count - 1)

        // Минимальная аренда — 1 сутки: одна выбранная дата всегда = 1 сут.
        if dayCount == 0 {
            durationLabel.text = "СРОК: 1 сут."
            view.setNeedsLayout()
            return
        }

        let minutesDiff = selectedEndMinutes - selectedStartMinutes
        let totalMinutes = dayCount * 24 * 60 + minutesDiff
        guard totalMinutes > 0 else {
            durationLabel.text = "СРОК: —"
            view.setNeedsLayout()
            return
        }
        let d = totalMinutes / (24 * 60)
        let h = (totalMinutes % (24 * 60)) / 60
        let m = totalMinutes % 60
        var parts: [String] = []
        if d > 0 { parts.append("\(d) сут.") }
        if h > 0 { parts.append("\(h) ч.") }
        if m > 0 { parts.append("\(m) мин.") }
        durationLabel.text = "СРОК: " + (parts.isEmpty ? "—" : parts.joined(separator: " "))
        view.setNeedsLayout()
    }

    // MARK: - Price

    private func formatPrice(_ value: Int) -> String {
        Self.priceFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func priceInfo() -> (formula: String, total: String)? {
        guard let dailyPrice, dailyPrice > 0, !datesRange.isEmpty else { return nil }

        let dayCount = max(0, datesRange.count - 1)

        // Одна дата — минимум 1 сутки, почасовой тариф не применяется
        if dayCount == 0 {
            let fDaily = formatPrice(dailyPrice)
            return ("1 сут. × \(fDaily) ₽/сут.", "≈ \(fDaily) ₽")
        }

        let remainingMinutes = selectedEndMinutes - selectedStartMinutes
        let calc = RentalPriceCalculator.calculate(dailyPrice: dailyPrice, daysCount: dayCount, remainingMinutes: remainingMinutes)
        let fDaily = formatPrice(calc.dailyPrice)
        let fTotal = formatPrice(calc.totalRent)

        if calc.extraHours > 0 {
            let fHourly = formatPrice(calc.hourlyRate)
            if calc.discountPercent > 0 {
                return ("\(calc.daysCount) сут. × \(fDaily) ₽ − \(calc.discountPercent)% + \(calc.extraHours) ч. × \(fHourly) ₽", "≈ \(fTotal) ₽")
            } else {
                return ("\(calc.daysCount) сут. × \(fDaily) ₽ + \(calc.extraHours) ч. × \(fHourly) ₽", "≈ \(fTotal) ₽")
            }
        } else if calc.discountPercent > 0 {
            return ("\(calc.daysCount) сут. × \(fDaily) ₽ − \(calc.discountPercent)%", "≈ \(fTotal) ₽")
        } else {
            return ("\(calc.daysCount) сут. × \(fDaily) ₽/сут.", "≈ \(fTotal) ₽")
        }
    }

    private func updatePriceContainer() {
        guard showTimeSliders else { return }
        if let info = priceInfo() {
            priceFormulaLabel.text = info.formula
            priceTotalLabel.text = info.total
            priceContainerView.isHidden = false
        } else {
            priceContainerView.isHidden = true
        }
        view.setNeedsLayout()
    }

    // MARK: - Layout

    private func performLayout() {
        selectButton.pin
            .bottom()
            .horizontally(12)
            .height(50)
            .marginBottom(view.safeAreaInsets.bottom + 10)

        if showTimeSliders {
            // The scroll view fills the space between the safe-area top and the button.
            sliderScrollView.pin
                .top()
                .horizontally()
                .bottom(to: selectButton.edge.top)
                .marginTop(view.safeAreaInsets.top)

            // ── Top-down layout inside the scroll view ───────────────────────
            rangeHeaderLabel.pin
                .top(8)
                .horizontally(16)
                .sizeToFit(.width)

            let calTop = rangeHeaderLabel.frame.maxY + 4
            // Fixed calendar height: tall enough for any 6-week month.
            let calendarHeight: CGFloat = 320

            calendar.pin
                .top(calTop)
                .horizontally()
                .height(calendarHeight)

            shimmerView.pin
                .top(calTop)
                .horizontally()
                .height(calendarHeight)

            startSliderRow.pin
                .top(calTop + calendarHeight + 16)
                .horizontally(16)
                .height(30)

            endSliderRow.pin
                .below(of: startSliderRow)
                .marginTop(16)
                .horizontally(16)
                .height(30)

            durationLabel.pin
                .below(of: endSliderRow)
                .marginTop(12)
                .left(16)
                .sizeToFit()

            if !priceContainerView.isHidden {
                priceContainerView.pin
                    .below(of: durationLabel)
                    .marginTop(8)
                    .horizontally(16)
                    .height(60)
                priceFormulaLabel.pin
                    .top(10)
                    .horizontally(12)
                    .sizeToFit(.width)
                priceTotalLabel.pin
                    .below(of: priceFormulaLabel)
                    .marginTop(2)
                    .horizontally(12)
                    .sizeToFit(.width)
                sliderScrollView.contentSize = CGSize(
                    width: sliderScrollView.bounds.width,
                    height: priceContainerView.frame.maxY + 16
                )
            } else {
                priceContainerView.frame = .zero
                sliderScrollView.contentSize = CGSize(
                    width: sliderScrollView.bounds.width,
                    height: durationLabel.frame.maxY + 16
                )
            }

            // Slider row internals
            startTitleLabel.pin.left().vCenter().sizeToFit()
            startSlider.pin
                .after(of: startTitleLabel, aligned: .center)
                .marginLeft(12)
                .right()
                .height(30)

            endTitleLabel.pin.left().vCenter().sizeToFit()
            endSlider.pin
                .after(of: endTitleLabel, aligned: .center)
                .marginLeft(12)
                .right()
                .height(30)

        } else {
            calendar.pin
                .top()
                .horizontally()
                .bottom(to: selectButton.edge.top)
                .marginTop(view.safeAreaInsets.top)

            shimmerView.pin
                .top()
                .horizontally()
                .bottom(to: selectButton.edge.top)
                .marginTop(view.safeAreaInsets.top)
        }
    }

    // MARK: - Helper

    private func datesRange(from: Date, to: Date) -> [Date] {
        if from > to { return [] }
        var tempDate = from
        var array = [tempDate]
        while tempDate < to {
            tempDate = Calendar.current.date(byAdding: .day, value: 1, to: tempDate)!
            array.append(tempDate)
        }
        return array
    }

    // MARK: - API

    private func fetchAutoCalendar(autoId: String, month: Date = Date()) {
        let cal = Calendar.current
        let today = Date()

        var utcCal = Calendar(identifier: .gregorian)
        guard let utcTimeZone = TimeZone(identifier: "UTC") else { return }
        utcCal.timeZone = utcTimeZone

        let localComponents = cal.dateComponents([.year, .month], from: month)
        guard let firstDayUTC = utcCal.date(from: localComponents),
              let nextMonthFirstDayUTC = utcCal.date(byAdding: .month, value: 1, to: firstDayUTC),
              let dateTo = utcCal.date(byAdding: .second, value: -1, to: nextMonthFirstDayUTC) else { return }

        let isCurrentMonth = cal.isDate(month, equalTo: today, toGranularity: .month)
        let dateFrom = isCurrentMonth ? utcCal.startOfDay(for: today) : firstDayUTC

        let monthKey = Self.monthKeyFormatter.string(from: month)
        loadedMonths.insert(monthKey)

        let calendarWasHidden = calendar.isHidden

        let input = GetAutoCalendarInput(
            objectId: autoId,
            dateFrom: Self.apiDateFormatter.string(from: dateFrom),
            dateTo: Self.apiDateFormatter.string(from: dateTo)
        )
        rentApiFacade.getAutoCalendar(with: input) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case let .success(data):
                    data.forEach { self.calendarData[$0.date] = $0.isFree }
                    self.calendar.reloadData()
                    self.shimmerView.stopAnimating()
                    self.shimmerView.isHidden = true
                    self.calendar.isHidden = false
                case .failure:
                    self.loadedMonths.remove(monthKey)
                    let model = InfoBottomSheetModel.makeAutoCalendarLoadFailModel { [weak self] in
                        guard let self else { return }
                        if calendarWasHidden {
                            self.calendar.isHidden = true
                            self.shimmerView.isHidden = false
                            self.shimmerView.startAnimating()
                        }
                        self.fetchAutoCalendar(autoId: autoId, month: month)
                    }
                    self.coordinator.openInfoBottomSheetViewController(model: model)
                }
            }
        }
    }
}

// MARK: - FSCalendarDataSource

extension CalendarViewController: FSCalendarDataSource {}

// MARK: - FSCalendarDelegate

extension CalendarViewController: FSCalendarDelegate {
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        guard let autoId else { return }
        let page = calendar.currentPage
        guard Calendar.current.compare(page, to: Date(), toGranularity: .month) != .orderedAscending else { return }
        let monthKey = Self.monthKeyFormatter.string(from: page)
        guard !loadedMonths.contains(monthKey) else { return }
        fetchAutoCalendar(autoId: autoId, month: page)
    }

    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        guard date >= Calendar.current.startOfDay(for: Date()) else { return false }
        let dateString = Self.calendarDateFormatter.string(from: date)
        if let isFree = calendarData[dateString] {
            return isFree
        }
        return true
    }

    /// Разрешаем снимать выделение только с первой или последней даты диапазона.
    /// Средние даты нельзя убрать тапом — это предотвращает "дыры" в диапазоне.
    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        date == firstDate || date == lastDate
    }

    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if date == lastDate {
            // Укорачиваем диапазон с конца
            let newRange = Array(datesRange.dropLast())
            if newRange.isEmpty {
                firstDate = nil
                lastDate = nil
                datesRange = []
            } else {
                lastDate = newRange.count == 1 ? nil : newRange.last
                datesRange = newRange
            }
        } else if date == firstDate {
            // Укорачиваем диапазон с начала
            let newRange = Array(datesRange.dropFirst())
            if newRange.isEmpty {
                firstDate = nil
                lastDate = nil
                datesRange = []
            } else {
                firstDate = newRange.first
                if newRange.count == 1 { lastDate = nil }
                datesRange = newRange
            }
        }
        updateClearButton()
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if firstDate == nil {
            firstDate = date
            datesRange = [firstDate!]
            updateClearButton()
            return
        }

        if firstDate != nil && lastDate == nil {
            if date <= firstDate! {
                calendar.deselect(firstDate!)
                firstDate = date
                datesRange = [firstDate!]
                updateClearButton()
                return
            }
            let range = datesRange(from: firstDate!, to: date)
            lastDate = range.last
            for date in range { calendar.select(date) }
            datesRange = range
            updateClearButton()
            return
        }

        if firstDate != nil && lastDate != nil {
            for selectedDate in calendar.selectedDates { calendar.deselect(selectedDate) }
            lastDate = nil
            firstDate = date
            datesRange = [date]
            calendar.select(date)
            updateClearButton()
        }
    }
}

// MARK: - FSCalendarDelegateAppearance

extension CalendarViewController: FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        guard date >= Calendar.current.startOfDay(for: Date()) else { return .secondaryTextColor }
        let dateString = Self.calendarDateFormatter.string(from: date)
        guard let isFree = calendarData[dateString] else { return nil }
        return isFree ? .whiteTextColor : .secondaryTextColor
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor? {
        let dateString = Self.calendarDateFormatter.string(from: date)
        guard let isFree = calendarData[dateString], isFree else { return nil }
        return .whiteTextColor
    }

}
