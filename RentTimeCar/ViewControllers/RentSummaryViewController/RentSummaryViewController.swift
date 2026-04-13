//
//  RentSummaryViewController.swift
//  RentTimeCar
//
//  Created by Андрей Пермяков on 09.02.2026.
//

import UIKit
import PinLayout

final class RentSummaryViewController: UIViewController {

    // MARK: - Private properties
    private let coordinator: ICoordinator
    private var cells: [RentSummaryCellModel] = []

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(cell: RentSummaryCollectionViewCell.self)
        collectionView.register(cell: RentSeparatorCollectionViewCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    private let prepayTitleLabel = Label(
        text: "Предоплата для брони авто",
        numberOfLines: 1,
        fontSize: 14,
        textColor: .secondaryTextColor,
        textAlignment: .left
    )

    private let infoButton = IconButton(image: .info)

    private let prepayValueLabel = Label(
        text: "5000 ₽",
        numberOfLines: 1,
        textAlignment: .right
    )

    private let continueButton = MainButton(
        title: "Подтвердить и оплатить 5000 ₽"
    )

    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.alpha = 0
        return view
    }()

    private let infoTooltipView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondaryBackground
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.secondaryTextColor.cgColor
        view.alpha = 0
        return view
    }()

    private let infoTooltipLabel = Label(
        text: "В случае отказа от аренды предоплата не возвращается. Можно будет перенести аренду на другую дату",
        numberOfLines: 0,
        fontSize: 12,
        textColor: .whiteTextColor,
        textAlignment: .center
    )

    // MARK: - Init
    init(coordinator: ICoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
        loadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layout()
    }

    // MARK: - Private methods (Payment)
    private func proceedToPayment() {
        coordinator.openYukassaPayment(
            amount: YukassaService.prepayAmount,
            description: "Предоплата аренды автомобиля"
        )
    }

    private func tapInfoButton() {
        UIView.animate(withDuration: 0.2) {
            self.dimmingView.alpha = 1
            self.infoTooltipView.alpha = 1
        }
    }

    private func hideTooltip() {
        UIView.animate(withDuration: 0.2) {
            self.dimmingView.alpha = 0
            self.infoTooltipView.alpha = 0
        }
    }

    // MARK: - Private methods
    private func setupViews() {
        view.backgroundColor = .mainBackground
        infoTooltipView.addSubview(infoTooltipLabel)
        view.addSubviews([collectionView, prepayTitleLabel, infoButton, prepayValueLabel, continueButton, dimmingView, infoTooltipView])
    }

    private func setupActions() {
        continueButton.action = { [weak self] in
            self?.proceedToPayment()
        }
        
        infoButton.action = { [weak self] in
            self?.tapInfoButton()
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDimmingTap))
        dimmingView.addGestureRecognizer(tapGesture)
    }

    @objc private func handleDimmingTap() {
        hideTooltip()
    }

    private func discountPercent(for daysCount: Int) -> Int {
        guard daysCount > 1 else { return 0 }
        return min(daysCount - 1, 30)
    }

    private func loadData() {
        let service = OrderConfirmService.shared
        guard let auto = service.auto else { return }

        var result: [RentSummaryCellModel] = []

        let daysCount = service.datesCount
        let discount = discountPercent(for: daysCount)
        let baseRent = auto.defaultPriceWithDiscountSt * daysCount
        let discountedRent = Int(Double(baseRent) * (1.0 - Double(discount) / 100.0))
        let discountText: String? = discount > 0 ? "Скидка \(discount)%" : nil
        result.append(.item(RentItem(title: "Аренда", amount: discountedRent, icon: .calendar, discountText: discountText)))
        result.append(.separator)

        let selectedServices = service.selectedServices
        var extrasTotal = 0
        if !selectedServices.isEmpty {
            result.append(.item(RentItem(title: "Дополнительные опции:", amount: 0, icon: .file)))
            for extra in selectedServices {
                let price = extra.effectivePrice
                extrasTotal += price
                let amountText: String? = price == 0 ? "Бесплатно" : nil
                result.append(.item(RentItem(title: " •  \(extra.serviceTitle)", amount: price, icon: nil, amountText: amountText)))
            }
        }

        result.append(.separator)
        result.append(.item(RentItem(title: "Итого", amount: discountedRent + extrasTotal, icon: .rublesign)))
        result.append(.item(RentItem(title: "Депозит", amount: auto.deposit, icon: .rublesignBank)))

        cells = result
        collectionView.reloadData()
    }

    private func layout() {
        let horizontalInset: CGFloat = 32
        let continueButtonHeight: CGFloat = 50
        let prepayHeight: CGFloat = 40
        let prepaySpacing: CGFloat = 8
        let prepayBottomMargin: CGFloat = 16

        continueButton.pin
            .horizontally(horizontalInset)
            .bottom(view.pin.safeArea.bottom)
            .height(continueButtonHeight)

        prepayTitleLabel.pin
            .bottom(to: continueButton.edge.top)
            .marginBottom(prepayBottomMargin)
            .left(horizontalInset)
            .height(prepayHeight)
            .sizeToFit()

        infoButton.pin
            .vCenter(to: prepayTitleLabel.edge.vCenter)
            .after(of: prepayTitleLabel)
            .marginLeft(prepaySpacing)
            .size(CGSize(square: 20))

        prepayValueLabel.pin
            .vCenter(to: prepayTitleLabel.edge.vCenter)
            .right(horizontalInset)
            .sizeToFit()

        collectionView.pin
            .top(view.pin.safeArea.top)
            .horizontally()
            .above(of: prepayTitleLabel)

        dimmingView.pin.all()

        let tooltipHPadding: CGFloat = 12
        let tooltipVPadding: CGFloat = 6
        let tooltipSpacing: CGFloat = 8
        let tooltipMaxWidth = view.bounds.width - horizontalInset * 2

        let labelSize = infoTooltipLabel.sizeThatFits(CGSize(width: tooltipMaxWidth - tooltipHPadding * 2, height: .greatestFiniteMagnitude))
        infoTooltipLabel.frame.size = labelSize

        let tooltipWidth = min(labelSize.width + tooltipHPadding * 2, tooltipMaxWidth)
        let tooltipHeight = labelSize.height + tooltipVPadding * 2
        let idealLeft = infoButton.frame.midX - tooltipWidth / 2
        let clampedLeft = min(max(idealLeft, horizontalInset), view.bounds.width - horizontalInset - tooltipWidth)

        infoTooltipView.pin
            .left(clampedLeft)
            .width(tooltipWidth)
            .height(tooltipHeight)
            .bottom(to: infoButton.edge.top)
            .marginBottom(tooltipSpacing)
        infoTooltipLabel.pin
            .horizontally(tooltipHPadding)
            .vCenter()
            .sizeToFit()
    }
}

// MARK: - UICollectionViewDataSource
extension RentSummaryViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cells.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch cells[indexPath.item] {
        case .item(let item):
            let cell: RentSummaryCollectionViewCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(with: item)
            return cell
        case .separator:
            let cell: RentSeparatorCollectionViewCell = collectionView.dequeueCell(for: indexPath)
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension RentSummaryViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch cells[indexPath.item] {
        case .item(let item):
            let height: CGFloat = item.discountText != nil ? 60 : 44
            return CGSize(width: collectionView.bounds.width, height: height)
        case .separator:
            return CGSize(width: collectionView.bounds.width, height: 1)
        }
    }
}
