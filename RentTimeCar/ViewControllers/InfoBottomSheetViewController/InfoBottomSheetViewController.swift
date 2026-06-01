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
    let cancelButtonTitle: String?
    let onConfirm: () -> Void
    let onCancel: (() -> Void)?

    init(
        text: String,
        image: UIImage,
        buttonTitle: String,
        cancelButtonTitle: String? = nil,
        onConfirm: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        self.text = text
        self.image = image
        self.buttonTitle = buttonTitle
        self.cancelButtonTitle = cancelButtonTitle
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }
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

    static func makePaymentCancelConfirmationModel(onConfirm: @escaping () -> Void) -> InfoBottomSheetModel {
        InfoBottomSheetModel(
            text: "Вы уверены, что хотите прервать оплату?",
            image: .redCross,
            buttonTitle: "Да, отменить",
            onConfirm: onConfirm
        )
    }

    static func makeAutoCalendarLoadFailModel(onConfirm: @escaping () -> Void) -> InfoBottomSheetModel {
        InfoBottomSheetModel(
            text: "Не удалось загрузить расписание автомобиля.\n\nПроверьте подключение к интернету и попробуйте ещё раз.",
            image: .redCross,
            buttonTitle: "Повторить",
            onConfirm: onConfirm
        )
    }

    static func makeOfficeAddressLoadFailModel(onConfirm: @escaping () -> Void) -> InfoBottomSheetModel {
        InfoBottomSheetModel(
            text: "Не удалось загрузить адрес офиса.\n\nПроверьте подключение к интернету и попробуйте ещё раз.",
            image: .redCross,
            buttonTitle: "Повторить",
            onConfirm: onConfirm
        )
    }
    
    static func makeAuthFailModel(onConfirm: @escaping () -> Void) -> InfoBottomSheetModel {
        InfoBottomSheetModel(
            text: "Не удалось войти.\n\nПроверьте подключение к интернету и попробуйте ещё раз.",
            image: .redCross,
            buttonTitle: "Понятно",
            onConfirm: onConfirm
        )
    }
    
    static func makeCreateContractFailModel(onConfirm: @escaping () -> Void) -> InfoBottomSheetModel {
        InfoBottomSheetModel(
            text: "Не удалось создать договор аренды.\n\nПроверьте подключение к интернету и попробуйте ещё раз.",
            image: .redCross,
            buttonTitle: "Понятно",
            onConfirm: onConfirm
        )
    }

    static func makeFailUploadImagesModel() -> InfoBottomSheetModel {
        InfoBottomSheetModel(
            text: "Не удалось отправить фото на проверку.\n\nСвязитесь со службой поддержки.",
            image: .redCross,
            buttonTitle: "Хорошо",
            onConfirm: {}
        )
    }

    static func makeDeleteAccountModel(onConfirm: @escaping () -> Void) -> InfoBottomSheetModel {
        InfoBottomSheetModel(
            text: "Для удаления аккаунта и всех персональных данных обратитесь в службу поддержки.\n\nМы обработаем запрос в течение 30 дней.",
            image: .redCross,
            buttonTitle: "Написать в поддержку",
            cancelButtonTitle: "Отмена",
            onConfirm: onConfirm
        )
    }

    static func makeLogoutModel(onConfirm: @escaping () -> Void) -> InfoBottomSheetModel {
        InfoBottomSheetModel(
            text: "Вы уверены, что хотите выйти из аккаунта?",
            image: .info,
            buttonTitle: "Выйти",
            cancelButtonTitle: "Отмена",
            onConfirm: onConfirm
        )
    }
}

final class InfoBottomSheetViewController: UIViewController {
    // MARK: - UI

    private let label = Label()
    private let imageView = UIImageView()
    private let confirmButton = MainButton(title: "")
    private let cancelButton = SecondaryButton(title: "")

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
        view.addSubviews([label, imageView, confirmButton, cancelButton])
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

        if let cancelTitle = model.cancelButtonTitle {
            cancelButton.setTitle(cancelTitle, for: .normal)
            cancelButton.isHidden = false
            cancelButton.action = { [weak self] in
                self?.dismiss(animated: true) {
                    self?.model.onCancel?()
                }
            }
        } else {
            cancelButton.isHidden = true
        }
    }

    private func performLayout() {
        let hasCancelButton = !cancelButton.isHidden

        if hasCancelButton {
            cancelButton.pin
                .bottom()
                .marginBottom(20)
                .horizontally(20)
                .height(50)

            confirmButton.pin
                .above(of: cancelButton)
                .marginBottom(12)
                .horizontally(20)
                .height(50)
        } else {
            confirmButton.pin
                .bottom()
                .marginBottom(20)
                .horizontally(20)
                .height(50)
        }

        label.pin
            .above(of: confirmButton)
            .marginBottom(30)
            .horizontally(16)
            .sizeToFit(.width)

        imageView.pin
            .above(of: label, aligned: .center)
            .marginBottom(16)
            .size(CGSize(square: 32))
    }
}
