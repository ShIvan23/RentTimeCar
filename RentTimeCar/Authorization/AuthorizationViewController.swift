//
//  AuthorizationViewController.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 30.07.2025.
//

import PinLayout
import UIKit

final class AuthorizationViewController: UIViewController {
    // MARK: - UI
    
    private let scrollView = UIScrollView()
    private let label = Label(
        text: "Введите номер вашего телефона, чтобы мы выслали вам код доступа",
        fontSize: 13,
        textColor: .white
    )
    private let codePhoneLabel = Label(
        text: "+7",
        fontSize: 22
    )
    private let phoneTextField = PhoneNumberTextField()
    
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
        view.addSubview(scrollView)
        scrollView.addSubviews([label, codePhoneLabel, phoneTextField])
        scrollView.backgroundColor = .red
        view.addTapGestureClosure { [weak self] in
            self?.view.endEditing(true)
            print("+++ endEditing")
        }
    }
    
    private func performLayout() {
        scrollView.pin
            .all(view.pin.safeArea)
        
        label.pin
            .top()
            .horizontally()
            .marginHorizontal(20)
            .sizeToFit(.width)
        
        codePhoneLabel.pin
            .below(of: label)
            .left()
            .marginTop(40)
            .marginLeft(30)
            .sizeToFit()
        
        phoneTextField.pin
            .left(to: codePhoneLabel.edge.right)
            .right()
            .marginLeft(12)
            .marginRight(20)
            .vCenter(to: codePhoneLabel.edge.vCenter)
            .height(50)
    }
}
