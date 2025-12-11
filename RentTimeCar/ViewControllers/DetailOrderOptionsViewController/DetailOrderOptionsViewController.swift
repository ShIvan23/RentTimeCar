//
//  DetailOrderOptionsViewController.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 10.12.2025.
//

import UIKit

struct DetailOrderOptionModel {
    let image: UIImage
    let title: String
    let subtitle: String
    let type: CellType

    enum CellType {
        case protection
        case child
        case additionalDriver
    }
}

extension DetailOrderOptionModel {
    static func makeModel() -> [DetailOrderOptionModel] {
        [
            DetailOrderOptionModel(
                image: .shield,
                title: "100% Защита",
                subtitle: "тут надо с бека взять цену",
                type: .protection
            ),
            DetailOrderOptionModel(
                image: .user,
                title: "Доп. водитель",
                subtitle: "тут надо с бека взять цену",
                type: .additionalDriver
            ),
            DetailOrderOptionModel(
                image: .child,
                title: "Детское кресло",
                subtitle: "Бесплатно",
                type: .child
            )
        ]
    }
}

final class DetailOrderOptionsViewController: UIViewController {
    // MARK: - Private Properties

    private let coordinator: ICoordinator
    private let model = DetailOrderOptionModel.makeModel()

    // MARK: - UI

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 20

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .mainBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cell: DetailOrderOptionCell.self)
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
        view.backgroundColor = .mainBackground
        view.addSubviews([collectionView, buttonContainerView])
        buttonContainerView.addSubview(continueButton)
        continueButton.action = { [weak self] in
            print("navigate")
        }
    }

    private func performLayout() {
        collectionView.pin
            .top(view.safeAreaInsets.top)
            .horizontally()
            .bottom(view.safeAreaInsets.bottom)

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
    }
}

// MARK: - UICollectionViewDataSource

extension DetailOrderOptionsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        model.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: DetailOrderOptionCell = collectionView.dequeueCell(for: indexPath)
        cell.configure(
            with: model[indexPath.row],
            delegate: self
        )
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension DetailOrderOptionsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(
            width: collectionView.bounds.width - .collectionViewCellHorizontalMargin * 2,
            height: 60
        )
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 30)
    }
}

extension DetailOrderOptionsViewController: TitleSubtitleViewDelegate {
    func didTapInfo(for cellType: DetailOrderOptionModel.CellType) {
        coordinator.openDetailOrderInfoBottomSheetViewController(type: cellType)
    }
}

private extension CGFloat {
    static let buttonHeight: CGFloat = 50
    static let buttonVerticalMargin: CGFloat = 8

    static let collectionViewCellHorizontalMargin: CGFloat = 16
}
