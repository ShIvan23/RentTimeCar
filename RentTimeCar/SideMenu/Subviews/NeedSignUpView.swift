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
    weak var delegate: NeedSignUpViewDelegate?
    
    private let label = Label(
        text: "Для подробной информации необходимо авторизоваться",
        fontSize: 13,
        textColor: .systemGray3
    )
    private let button = MainButton(title: "Войти")
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        performLayout()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
       autoSizeThatFits(size, layoutClosure: performLayout)
    }
    
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
            .marginHorizontal(12)
            .height(50)
    }
}
