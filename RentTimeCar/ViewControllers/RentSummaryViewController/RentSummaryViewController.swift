//
//  RentSummaryViewController.swift
//  RentTimeCar
//
//  Created by Андрей Пермяков on 09.02.2026.
//

import UIKit

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
    
    private let infoButton = IconButton(
        image: .info
        
    )
    
    private let prepayValueLabel = Label(
        text: "5000 ₽",
        numberOfLines: 1,
        fontSize: 16,
        textColor: .whiteTextColor,
        textAlignment: .right
    )
    
    private let continueButton = MainButton(title: "Подтвердить и оплатить 5000 ₽")
    
    init (coordinator: ICoordinator) {
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
        loadData()
    }
    
    private func setupViews() {
        [collectionView, stackView, continueButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: stackView.topAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalToConstant: 40),
            
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        configureStackView()
        setupActions()
    }
    
    private func configureStackView() {
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(prepayTitleLabel)
        stackView.addArrangedSubview(infoButton)
        stackView.addArrangedSubview(prepayValueLabel)
        
        stackView.setCustomSize(CGSize(width: 20, height: 20), for: infoButton)
    }
    
    private func loadData() {
        let selectedOptions = OrderConfirmService.shared.selectedOptions
        items = RentSummaryService.shared.getRentSummaryItems(selectedOptions: selectedOptions)
        collectionView.reloadData()
    }
    
    private func setupActions() {
        continueButton.action = { [weak self] in self?.proceedToPayment() }
        infoButton.action = { [weak self] in self?.tapInfoButton() }
    }
    
    private func proceedToPayment() {
        print("+++ navigate переход на экран оплаты")
    }
    
    private func tapInfoButton() {
        print("+++ tapInfoButon RentSummaryVC")
    }
}

extension RentSummaryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: RentSummaryCollectionViewCell = collectionView.dequeueCell(for: indexPath)
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
        CGSize(width: collectionView.frame.width, height: 44)
    }
}
