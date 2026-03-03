//
//  InfoBottomSheetViewController.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 28.02.2026.
//

import UIKit

struct InfoBottomSheetModel {
    let text: String
    let image: UIImage
}

extension InfoBottomSheetModel {
    static func makeDeniedCameraPermissionModel() -> InfoBottomSheetModel {
        InfoBottomSheetModel(
            text: "Чтобы дать доступ к камере вам нужно перейти в настройки.\n\n1. В настройках зайдите в раздел Приложения\n2. Далее найдите наше приложение\n3. Разрешите доступ к камере",
            image: .info
        )
    }
}

final class InfoBottomSheetViewController: UIViewController {
    // MARK: - UI

    private let label = Label()
    private let confirmButton = MainButton(title: "Перейти в настройки")
    private let imageView = UIImageView()

    // MARK: - Private Properties

    private let coordinator: ICoordinator

    // MARK: - Init

    init(
        coordinator: ICoordinator,
        model: InfoBottomSheetModel
    ) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        label.text = model.text
        imageView.image = model.image.withRenderingMode(.alwaysTemplate)
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
        confirmButton.action = { [weak self] in
            guard let self else { return }
            coordinator.openSettingsApp()
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
