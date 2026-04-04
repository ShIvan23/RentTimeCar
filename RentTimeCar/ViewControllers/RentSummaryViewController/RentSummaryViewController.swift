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
        let prepayAmount = 5000  // сумма предоплаты в рублях

        coordinator.openYukassaPayment(
            amount: prepayAmount,
            description: "Предоплата аренды автомобиля"
        ) { [weak self] in
            self?.handlePaymentSuccess()
        } onFail: { [weak self] in
            self?.handlePaymentFail()
        }
    }

    private func handlePaymentSuccess() {
        coordinator.openPaymentSuccessBottomSheet { [weak self] in
            self?.coordinator.popToRootViewController()
        }
    }

    private func handlePaymentFail() {
        coordinator.openPaymentFailBottomSheet { [weak self] in
            self?.coordinator.popViewController()
        }
    }

    private func tapInfoButton() {
        print("+++ tapInfoButton RentSummaryVC")
    }

    // MARK: - Private methods
    private func setupViews() {
        view.backgroundColor = .mainBackground
        view.addSubviews([collectionView, prepayTitleLabel, infoButton, prepayValueLabel, continueButton])
    }

    private func setupActions() {
        continueButton.action = { [weak self] in
            self?.proceedToPayment()
        }
        
        infoButton.action = { [weak self] in
            self?.tapInfoButton()
        }
    }

    private func loadData() {
        let service = OrderConfirmService.shared
        guard let auto = service.auto else { return }

        var result: [RentSummaryCellModel] = []

        let baseRent = auto.defaultPriceWithDiscountSt * service.datesCount
        result.append(.item(RentItem(title: "Аренда", amount: baseRent, icon: .calendar)))
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
        result.append(.item(RentItem(title: "Итого", amount: baseRent + extrasTotal, icon: .rublesign)))
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
        case .item:
            return CGSize(width: collectionView.bounds.width, height: 44)
        case .separator:
            return CGSize(width: collectionView.bounds.width, height: 1)
        }
    }
}
