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
        case unowned
    }
}

extension DetailOrderOptionModel {
    static func makeModel(additionalServices: [AdditionalService]) -> [DetailOrderOptionModel] {
        var models = additionalServices.map { service -> DetailOrderOptionModel in
            let subtitle = service.effectivePrice > 0 ? "\(service.effectivePrice) ₽" : "Бесплатно"
            switch service.serviceTitle {
            case .additionalDriverTitle:
                return DetailOrderOptionModel(image: .user, title: service.serviceTitle, subtitle: subtitle, type: .additionalDriver)
            case .protectionTitle:
                return DetailOrderOptionModel(image: .shield, title: service.serviceTitle, subtitle: subtitle, type: .protection)
            default:
                return DetailOrderOptionModel(image: .file, title: service.serviceTitle, subtitle: subtitle, type: .unowned)
            }
        }
        models.insert(
            DetailOrderOptionModel(
                image: .child,
                title: "Детское кресло",
                subtitle: "Бесплатно",
                type: .child
            ),
            at: .zero)
        return models
    }
}

private extension String {
    static let additionalDriverTitle = "Дополнительный водитель"
    static let protectionTitle = "Полная защита"
}

final class DetailOrderOptionsViewController: UIViewController {
    // MARK: - Private Properties

    private let coordinator: ICoordinator
    private var model = [DetailOrderOptionModel]()
    private var selectedOptions = [String]()

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
        buildModel()
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
            self?.saveChangesInOrderConfirmService()
            self?.coordinator.openOrderConfirmViewController()
        }
    }

    private func buildModel() {
        let services = OrderConfirmService.shared.auto?.additionalServices ?? []
        model = DetailOrderOptionModel.makeModel(additionalServices: services)
        collectionView.reloadData()
    }

    private func saveChangesInOrderConfirmService() {
        let orderConfirmService = OrderConfirmService.shared
        orderConfirmService.setSelectedOptions(selectedOptions)
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
            .top(view.safeAreaInsets.top)
            .horizontally()
            .bottom(to: buttonContainerView.edge.top)
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
            titleSubtitleViewDelegate: self,
            detailOrderOptionCellDelegate: self
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

// MARK: - TitleSubtitleViewDelegate

extension DetailOrderOptionsViewController: TitleSubtitleViewDelegate {
    func didTapInfo(for cellType: DetailOrderOptionModel.CellType) {
        coordinator.openDetailOrderInfoBottomSheetViewController(type: cellType)
    }
}

// MARK: - DetailOrderOptionCellDelegate

extension DetailOrderOptionsViewController: DetailOrderOptionCellDelegate {
    func switcherValueDidChange(_ value: Bool, text: String) {
        let isSelected = value
        if isSelected {
            selectedOptions.append(text)
        } else {
            selectedOptions.removeAll(where: { $0 == text })
        }
    }
}

private extension CGFloat {
    static let buttonHeight: CGFloat = 50
    static let buttonVerticalMargin: CGFloat = 8

    static let collectionViewCellHorizontalMargin: CGFloat = 16
}
