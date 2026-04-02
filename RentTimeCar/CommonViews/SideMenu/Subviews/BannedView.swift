//
//  BannedView.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 02.04.2026.
//

import PinLayout
import UIKit

final class BannedView: UIView {

    // MARK: - UI

    private let label = Label(
        text: "Ваш аккаунт заблокирован. Для разблокировки обратитесь в поддержку",
        numberOfLines: 0,
        fontSize: 13,
        textColor: .systemGray3,
        textAlignment: .center
    )
    private let supportButton = MainButton(title: "Поддержка")

    // MARK: - Private Properties

    private let coordinator: ICoordinator

    // MARK: - Init

    init(coordinator: ICoordinator) {
        self.coordinator = coordinator
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        performLayout()
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        autoSizeThatFits(size, layoutClosure: performLayout)
    }

    // MARK: - Private Methods

    private func setupView() {
        addSubviews([label, supportButton])
        supportButton.action = { [weak self] in
            self?.coordinator.openContactsViewController()
        }
    }

    private func performLayout() {
        label.pin
            .top()
            .horizontally(12)
            .sizeToFit(.width)

        supportButton.pin
            .below(of: label)
            .marginTop(16)
            .horizontally(12)
            .height(50)
    }
}
