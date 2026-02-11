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
    private var items: [RentItem] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(cell: RentSummaryCollectionViewCell.self)
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
        fontSize: 16,
        textColor: .whiteTextColor,
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
        view.backgroundColor = .systemBackground
        setupViews()
        setupActions()
        loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layout()
    }
    
    private func setupViews() {
        view.addSubviews([collectionView, stackView, continueButton])
        configureStackView()
    }
    
    private func configureStackView() {
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.addArrangedSubview(prepayTitleLabel)
        stackView.addArrangedSubview(infoButton)
        stackView.addArrangedSubview(prepayValueLabel)
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
        items = RentSummaryService.shared.getRentSummaryItems(
            selectedOptions: selectedOptions
        )
        collectionView.reloadData()
    }
    
    private func layout() {
        let HorizontalInset: CGFloat = 32
        let continueButtonHeight: CGFloat = 50
        let stackViewHeight: CGFloat = 40
        let stackViewBottomMargin: CGFloat = 16
        
        continueButton.pin
            .horizontally(HorizontalInset)
            .bottom(view.pin.safeArea.bottom)
            .height(continueButtonHeight)

        stackView.pin
            .width(continueButton.frame.width)
            .above(of: continueButton)
            .marginBottom(stackViewBottomMargin)
            .left(HorizontalInset)
            .right(HorizontalInset)
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
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: RentSummaryCollectionViewCell =
            collectionView.dequeueCell(for: indexPath)
        
        let item = items[indexPath.item]
        cell.configure(with: item)
        
        let isFirst = indexPath.item == 1
        let isBeforeLast = indexPath.item == items.count - 2
        cell.setSeparatorVisible(isFirst || isBeforeLast)
        
        return cell
    }
}

extension RentSummaryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 44)
    }
}
