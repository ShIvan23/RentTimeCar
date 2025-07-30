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
    
    private let phoneTextField = PhoneNumberTextField(
        placeholder: "000-000-00-00",
        keyboardType: .numberPad
    )
    
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
        view.backgroundColor = .black
        view.addSubview(scrollView)
        scrollView.addSubviews([label, phoneTextField])
        scrollView.backgroundColor = .red
        phoneTextField.backgroundColor = .darkGray
        view.addTapGestureClosure { [weak self] in
            self?.view.endEditing(true)
            print("+++ endEditing")
        }
    }
    
    private func performLayout() {
        scrollView.pin
            .all()
        
        label.pin
            .top()
            .horizontally()
            .marginHorizontal(20)
            .sizeToFit(.width)
        
        phoneTextField.pin
            .below(of: label)
            .horizontally()
            .marginTop(20)
            .marginHorizontal(20)
            .height(50)
        
    }
}
