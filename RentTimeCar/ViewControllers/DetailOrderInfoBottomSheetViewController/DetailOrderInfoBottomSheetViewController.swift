//
//  DetailOrderInfoBottomSheetViewController.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 11.12.2025.
//

import UIKit

final class DetailOrderInfoBottomSheetViewController: UIViewController {
    // MARK: - UI

    private let label = Label()
    private let confirmButton = MainButton(title: "Понятно")
    private let imageView = UIImageView()

    // MARK: - Private Properties

    private let type: DetailOrderOptionModel.CellType
    private let coordinator: ICoordinator

    // MARK: - Init

    init(
        type: DetailOrderOptionModel.CellType,
        coordinator: ICoordinator
    ) {
        self.type = type
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

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
        view.addSubviews([label, imageView, confirmButton])
        imageView.image = .info.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .whiteTextColor
        view.backgroundColor = .mainBackground
        let text: String
        switch type {
        case .protection:
            text = "Ответственность 0 руб. в любых ситуациях"
        case .child:
            text = "Автомобиль будет оборудован детскими креслами в соответсвии с Вашими запросами"
        case .additionalDriver:
            text = "Если управлять автомобилем планируете не только ВЫ, то каждого дополнительно водителя нужно будет указать в договоре"
        case .unowned:
            text = "Нет информации по этой услуге"
        }
        label.text = text
        confirmButton.action = { [weak self] in
            guard let self else { return }
            coordinator.dismissViewController()
        }
    }

    private func performLayout() {
        label.pin
            .vCenter()
            .horizontally()
            .marginHorizontal(16)
            .sizeToFit(.width)

        imageView.pin
            .above(of: label, aligned: .center)
            .marginBottom(30)
            .size(CGSize(square: 32))

        confirmButton.pin
            .bottom()
            .marginBottom(20)
            .horizontally()
            .marginHorizontal(20)
            .height(50)
    }
}
