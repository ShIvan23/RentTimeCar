//
//  RentSummaryViewController.swift
//  RentTimeCar
//
//  Created by Андрей Пермяков on 09.02.2026.
//

import UIKit
import PinLayout

final class RentSummaryViewController: UIViewController {
    
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
    
    private let stackView = ManualLayoutBasedStackView()
    
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
    
    init(coordinator: ICoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    private func setupViews() {
        view.backgroundColor = .mainBackground
        view.addSubviews([collectionView, stackView, continueButton])
        configureStackView()
    }
    
    private func configureStackView() {
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        [prepayTitleLabel, infoButton, prepayValueLabel].forEach { stackView.addArrangedSubview($0) }
        stackView.setCustomSize(CGSize(width: 20, height: 20), for: infoButton)
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
        let selectedOptions = OrderConfirmService.shared.selectedOptions
        let items = RentSummaryService.shared.getRentSummaryItems(
            selectedOptions: selectedOptions
        )
        
        cells = buildCellModels(from: items)
        collectionView.reloadData()
    }
    
    private func buildCellModels(from items: [RentItem]) -> [RentSummaryCellModel] {
        var result: [RentSummaryCellModel] = []
        
        for (index, item) in items.enumerated() {
            result.append(.item(item))
            if index == 0 || index == items.count - 3 {
                result.append(.separator)
            }
        }
        return result
    }
    
    private func layout() {
        let horizontalInset: CGFloat = 32
        let continueButtonHeight: CGFloat = 50
        let stackViewHeight: CGFloat = 40
        let stackViewBottomMargin: CGFloat = 16
        
        continueButton.pin
            .horizontally(horizontalInset)
            .bottom(view.pin.safeArea.bottom)
            .height(continueButtonHeight)
        
        stackView.pin
            .width(continueButton.frame.width)
            .above(of: continueButton)
            .marginBottom(stackViewBottomMargin)
            .horizontally(horizontalInset)
            .height(stackViewHeight)
        
        collectionView.pin
            .top(view.pin.safeArea.top)
            .horizontally()
            .above(of: stackView)
    }
    
    private func proceedToPayment() {
        print("+++ navigate переход на экран оплаты")
    }
    
    private func tapInfoButton() {
        print("+++ tapInfoButton RentSummaryVC")
    }
}

extension RentSummaryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch cells[indexPath.item] {

        case .item(let item):
            let cell: RentSummaryCollectionViewCell =
                collectionView.dequeueCell(for: indexPath)
            cell.configure(with: item)
            return cell

        case .separator:
            let cell: RentSeparatorCollectionViewCell =
                collectionView.dequeueCell(for: indexPath)
            return cell
        }
    }
}

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
