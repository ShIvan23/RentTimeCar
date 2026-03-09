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
    let buttonTitle: String
    let onConfirm: () -> Void
}

extension InfoBottomSheetModel {
    static func makeDeniedCameraPermissionModel(onConfirm: @escaping () -> Void) -> InfoBottomSheetModel {
        InfoBottomSheetModel(
            text: "Чтобы дать доступ к камере вам нужно перейти в настройки.\n\n1. В настройках зайдите в раздел Приложения\n2. Далее найдите наше приложение\n3. Разрешите доступ к камере",
            image: .info,
            buttonTitle: "Перейти в настройки",
            onConfirm: onConfirm
        )
    }

    static func makePaymentSuccessModel(onConfirm: @escaping () -> Void) -> InfoBottomSheetModel {
        InfoBottomSheetModel(
            text: "Оплата прошла успешно!\n\nБронирование подтверждено. Ожидайте звонка менеджера.",
            image: .rublesign,
            buttonTitle: "Отлично",
            onConfirm: onConfirm
        )
    }

    static func makePaymentFailModel(onConfirm: @escaping () -> Void) -> InfoBottomSheetModel {
        InfoBottomSheetModel(
            text: "Оплата не завершена.\n\nПопробуйте ещё раз или свяжитесь с поддержкой.",
            image: .redCross,
            buttonTitle: "Понятно",
            onConfirm: onConfirm
        )
    }
}

final class InfoBottomSheetViewController: UIViewController {
    // MARK: - UI

    private let label = Label()
    private let imageView = UIImageView()
    private let confirmButton = MainButton(title: "")

    // MARK: - Private Properties

    private let model: InfoBottomSheetModel

    // MARK: - Init

    init(model: InfoBottomSheetModel) {
        self.model = model
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
        view.backgroundColor = .mainBackground

        label.text = model.text
        imageView.image = model.image.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .whiteTextColor
        confirmButton.setTitle(model.buttonTitle, for: .normal)

        confirmButton.action = { [weak self] in
            self?.dismiss(animated: true) {
                self?.model.onConfirm()
            }
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
