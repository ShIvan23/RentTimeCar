//
//  NeedSignUpView.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 29.07.2025.
//

import PinLayout
import UIKit

protocol NeedSignUpViewDelegate: AnyObject {
    func signUpButtonTapped()
}

// Вьюха в боковом меню, которая говорит, что надо войти в приложение
final class NeedSignUpView: UIView {
    // MARK: - Internal Properties

    weak var delegate: NeedSignUpViewDelegate?

    // MARK: - UI

    private let label = Label(
        fontSize: 13,
        textColor: .systemGray3
    )
    private let button = MainButton()

    // MARK: - Init

    init() {
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

    // MARK: - Internal Methods

    func configure(with buttonType: MainViewController.CellType.ButtonType) {
        label.isHidden = buttonType == .onCheck
        button.isHidden = buttonType == .onCheck
        switch buttonType {
        case .authorization:
            label.text = .authorizationLabelText
            button.setTitle(.authorizationButtonText, for: .normal)
        case .registration:
            label.text = .registrationLabelText
            button.setTitle(.registrationButtonText, for: .normal)
        case .onCheck:
           break
        }
    }

    // MARK: - Private Methods

    private func setupView() {
        addSubviews([label, button])
        button.action = { [weak self] in
            self?.delegate?.signUpButtonTapped()
        }
    }
    
    private func performLayout() {
        label.pin
            .top()
            .horizontally()
            .marginHorizontal(12)
            .sizeToFit(.width)
        
        button.pin
            .below(of: label)
            .marginTop(16)
            .horizontally()
            .marginHorizontal(16)
            .height(50)
    }
}

private extension String {
    static let authorizationLabelText = "Для подробной информации необходимо авторизоваться"
    static let registrationLabelText = "Для бронирования машины необходимо зарегистрироваться"
    static let authorizationButtonText = "Войти"
    static let registrationButtonText = "Зарегистрироваться"
}
