//
//  CalendarViewController.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 09.09.2025.
//

import FSCalendar
import UIKit

final class CalendarViewController: UIViewController {
    // MARK: - UI

    private let calendar = FSCalendar()
    private let selectButton = MainButton(title: "Выбрать")
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .whiteTextColor
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Private Properties

    private let autoId: String?
    private let coordinator: ICoordinator
    private var firstDate: Date?
    private var lastDate: Date?
    private var datesRange = [Date]()
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

    private static let apiDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd.MM.yyyy HH:mm:ss"
        f.timeZone = TimeZone(identifier: "UTC")
        return f
    }()

    // MARK: - Init

    init(autoId: String? = nil, coordinator: ICoordinator) {
        self.autoId = autoId
        self.coordinator = coordinator
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
        setupCalendar()
        view.addSubviews([calendar, selectButton, activityIndicator])
        view.backgroundColor = .mainBackground
        setupButtonAction()
        if autoId != nil {
            calendar.isHidden = true
            activityIndicator.startAnimating()
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
        filterService.selectedDates.forEach {
            calendar.select($0)
        }
        datesRange = filterService.selectedDates
        firstDate = filterService.selectedDates.first
        lastDate = filterService.selectedDates.last
    }

    private func setupButtonAction() {
        selectButton.action = { [weak self] in
            guard let self else { return }
            sendSelectedDates()
            navigationController?.popViewController(animated: true)
        }
    }

    private func sendSelectedDates() {
        FilterService.shared.setSelectedDates(datesRange)
    }

    private func performLayout() {
        selectButton.pin
            .bottom()
            .horizontally()
            .height(50)
            .marginHorizontal(12)
            .marginBottom(view.safeAreaInsets.bottom + 10)

        calendar.pin
            .top()
            .horizontally()
            .bottom(to: selectButton.edge.top)
            .marginTop(view.safeAreaInsets.top)

        activityIndicator.pin
            .center()
    }

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

        // Используем UTC-календарь для построения дат, чтобы dateFrom/dateTo
        // точно покрывали полный месяц в UTC, без смещения часового пояса.
        var utcCal = Calendar(identifier: .gregorian)
        guard let utcTimeZone = TimeZone(identifier: "UTC") else { return }
        utcCal.timeZone = utcTimeZone

        // Год и месяц берём из локального календаря (FSCalendar возвращает даты в local-времени)
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
                self.activityIndicator.stopAnimating()
                switch result {
                case let .success(data):
                    data.forEach { self.calendarData[$0.date] = $0.isFree }
                    self.calendar.reloadData()
                    self.calendar.isHidden = false
                case .failure:
                    self.loadedMonths.remove(monthKey)
                    let model = InfoBottomSheetModel.makeAutoCalendarLoadFailModel { [weak self] in
                        guard let self else { return }
                        if calendarWasHidden { self.calendar.isHidden = true }
                        self.activityIndicator.startAnimating()
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
        // Не подгружаем прошедший месяц
        guard Calendar.current.compare(page, to: Date(), toGranularity: .month) != .orderedAscending else { return }
        // Не подгружаем уже загруженный месяц
        let monthKey = Self.monthKeyFormatter.string(from: page)
        guard !loadedMonths.contains(monthKey) else { return }
        activityIndicator.startAnimating()
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

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if firstDate == nil {
            firstDate = date
            datesRange = [firstDate!]
            return
        }

        if firstDate != nil && lastDate == nil {
            if date <= firstDate! {
                calendar.deselect(firstDate!)
                firstDate = date
                datesRange = [firstDate!]
                return
            }
            let range = datesRange(from: firstDate!, to: date)
            lastDate = range.last

            for date in range {
                calendar.select(date)
            }
            datesRange = range
            return
        }

        if firstDate != nil && lastDate != nil {
            for date in calendar.selectedDates {
                calendar.deselect(date)
            }
            lastDate = nil
            firstDate = nil
            datesRange = []
        }
    }
}

// MARK: - FSCalendarDelegateAppearance

extension CalendarViewController: FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
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
