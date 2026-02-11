//
//  OrderConfirmViewController.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 08.01.2026.
//

import UIKit

// Экран с подтверждением заказа, где выводится вся информация перед отправкой
final class OrderConfirmViewController: UIViewController {
    // MARK: - Private Properties

    private let coordinator: ICoordinator
    private var model = OrderConfirmModel.makeModel()
    private var stubTextCell = OrderConfirmTextCollectionViewCell()

    // MARK: - UI

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cell: OrderConfirmImageCollectionViewCell.self)
        collectionView.register(cell: OrderConfirmTextCollectionViewCell.self)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    private let continueButton = MainButton(title: "Продолжить")
    private let buttonContainerView = UIView()

    // MARK: - Init

    init(
        coordinator: ICoordinator
    ) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        performLayout()
    }

    // MARK: - Private Methods

    private func setupView() {
        view.addSubviews([collectionView, buttonContainerView])
        view.backgroundColor = .black
        buttonContainerView.addSubview(continueButton)
        continueButton.action = { [weak self] in
            self?.coordinator.openRentSummaryViewController()
        }
    }

    private func performLayout() {
        buttonContainerView.pin
            .bottom()
            .horizontally()
            .height(view.safeAreaInsets.bottom + .buttonHeight + .buttonVerticalMargin * 2)

        continueButton.pin
            .top()
            .horizontally()
            .marginVertical(.buttonVerticalMargin)
            .marginHorizontal(16)
            .height(.buttonHeight)

        collectionView.pin
            .top()
            .marginTop(view.safeAreaInsets.top)
            .horizontally()
            .bottom(to: buttonContainerView.edge.top)
    }
}

// MARK: - UICollectionViewDataSource

extension OrderConfirmViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        model.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = model[indexPath.item]
        switch item {
        case let .image(imageModel):
            let cell: OrderConfirmImageCollectionViewCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(with: imageModel)
            return cell

        case let .text(textModel):
            let cell: OrderConfirmTextCollectionViewCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(model: textModel)
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension OrderConfirmViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = model[indexPath.item]
        switch item {
        case .image:
            return CGSize(
                width: collectionView.bounds.width,
                height: collectionView.bounds.width / 4 * 3
            )
        case let .text(textModel):
            stubTextCell.configure(model: textModel)
            let cellSize = stubTextCell.sizeThatFits(
                CGSize(
                    width: collectionView.bounds.width,
                    height: .greatestFiniteMagnitude
                )
            )
            return CGSize(
                width: collectionView.bounds.width,
                height: cellSize.height
            )
        }
    }
}

private extension CGFloat {
    static let buttonHeight: CGFloat = 50
    static let buttonVerticalMargin: CGFloat = 8
}
