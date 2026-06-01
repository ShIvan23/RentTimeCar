//
//  SettingsViewController.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 01.06.2026.
//

import UIKit

final class SettingsViewController: UIViewController {

    // MARK: - UI

    private let phoneLabel = Label(
        text: "",
        fontSize: 14,
        textColor: .secondaryTextColor,
        textAlignment: .left
    )

    private let sectionLabel = Label(
        text: "АККАУНТ",
        fontSize: 12,
        textColor: .secondaryTextColor,
        textAlignment: .left
    )

    private let logoutButton = MainButton(title: "Выйти из аккаунта")

    private lazy var deleteAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Удалить аккаунт", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = UIFont.openSans(fontSize: 16)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.4).cgColor
        button.addTarget(self, action: #selector(deleteAccountTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Private Properties

    private let coordinator: ICoordinator

    // MARK: - Init

    init(coordinator: ICoordinator) {
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
        title = "Настройки"
        view.backgroundColor = .mainBackground
        view.addSubviews([sectionLabel, phoneLabel, logoutButton, deleteAccountButton])

        if let phone = AuthService.shared.phoneNumber, !phone.isEmpty {
            let formatted = phone.applyPhoneNumberMask()
            phoneLabel.text = "Номер: +7 \(formatted)"
        }

        logoutButton.action = { [weak self] in
            guard let self else { return }
            coordinator.openLogoutBottomSheet { [weak self] in
                AuthService.shared.logout()
                self?.coordinator.popToRootViewController()
            }
        }
    }

    @objc
    private func deleteAccountTapped() {
        coordinator.openDeleteAccountBottomSheet { [weak self] in
            self?.coordinator.openContactsViewController()
        }
    }

    private func performLayout() {
        phoneLabel.pin
            .top(view.safeAreaInsets.top + 24)
            .horizontally(20)
            .sizeToFit(.width)

        sectionLabel.pin
            .below(of: phoneLabel)
            .horizontally(20)
            .marginTop(phoneLabel.text?.isEmpty == false ? 24 : 0)
            .sizeToFit(.width)

        logoutButton.pin
            .below(of: sectionLabel)
            .horizontally(20)
            .marginTop(12)
            .height(50)

        deleteAccountButton.pin
            .below(of: logoutButton)
            .horizontally(20)
            .marginTop(12)
            .height(50)
    }
}
