//
//  AuthorizationViewController.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 30.07.2025.
//

import PinLayout
import UIKit

// Экран для ввода номера и получения кода по смс
final class AuthorizationViewController: UIViewController, ToastViewShowable {
    // MARK: - ToastViewShowable
    
    var showingToast: ToastView?
    
    // MARK: - UI
    
    private var isKeyboardShow = false
    private let scrollView = UIScrollView()
    private let label = Label(
        text: "Введите номер вашего телефона, чтобы мы выслали вам код доступа",
        fontSize: 14,
        textColor: .white
    )
    private let codePhoneLabel = Label(
        text: "+7",
        fontSize: 22
    )
    private let phoneTextField = PhoneNumberTextField()
    private let getCodeButton = MainButton(title: "Получить код")
    private let taggedLabel = TaggedLabel()
    private let codePhoneBorderView = UIView()
    private let phoneTextFieldBorderView = UIView()
    
    // MARK: - Private Properties
    
    private let coordinator: ICoordinator
    
    // MARK: - Init
    
    init(coordinator: ICoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addKeyboardObservers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        performLayout()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeKeyboardObservers()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        view.backgroundColor = .black
        view.addSubview(scrollView)
        scrollView.addSubviews([label, codePhoneLabel, phoneTextField, codePhoneBorderView, phoneTextFieldBorderView, getCodeButton, taggedLabel])
        taggedLabel.delegate = self
        setupBorderViews()
        getCodeButtonAction()
        addTapGesture()
    }
    
    private func getCodeButtonAction() {
        getCodeButton.action = { [weak self] in
            guard let self,
                  phoneTextField.validatePhone() else {
                self?.showToast(with: "Номер телефона введен не верно")
                return
            }
            print("+++ отправить запрос на получение кода")
        }
    }
    
    private func setupBorderViews() {
        codePhoneBorderView.backgroundColor = .systemGray4
        phoneTextFieldBorderView.backgroundColor = .systemGray4
    }
    
    private func addTapGesture() {
        view.addTapGestureClosure { [weak self] in
            self?.view.endEditing(true)
        }
    }
    
    private func performLayout() {
        scrollView.pin
            .all(view.pin.safeArea)
        
        let codeLabelTopMargin: CGFloat = 40
        
        label.pin
            .top(isKeyboardShow ? 60 : 160)
            .horizontally()
            .marginHorizontal(20)
            .sizeToFit(.width)
        
        codePhoneLabel.pin
            .below(of: label)
            .left()
            .marginTop(codeLabelTopMargin)
            .marginLeft(30)
            .sizeToFit()
        
        codePhoneBorderView.pin
            .below(of: codePhoneLabel)
            .left(to: codePhoneLabel.edge.left)
            .right(to: codePhoneLabel.edge.right)
            .height(1)
        
        let textFieldLeftMargin: CGFloat = 12
        phoneTextField.pin
            .left(to: codePhoneLabel.edge.right)
            .right()
            .marginLeft(textFieldLeftMargin)
            .marginRight(20)
            .vCenter(to: codePhoneLabel.edge.vCenter)
            .height(50)
        
        phoneTextFieldBorderView.pin
            .after(of: codePhoneBorderView)
            .right(to: phoneTextField.edge.right)
            .marginLeft(textFieldLeftMargin)
            .vCenter(to: codePhoneBorderView.edge.vCenter)
            .height(1)
        
        if isKeyboardShow {
            let getCodeButtonTopMargin: CGFloat = 16
            getCodeButton.pin
                .below(of: phoneTextField)
                .horizontally()
                .marginTop(getCodeButtonTopMargin)
                .marginHorizontal(20)
                .height(50)
            
            taggedLabel.pin
                .below(of: getCodeButton)
                .horizontally()
                .marginTop(20)
                .marginHorizontal(20)
                .sizeToFit(.width)
            
            let totalContentHeight = label.frame.height + codeLabelTopMargin + phoneTextField.frame.height + getCodeButtonTopMargin + getCodeButton.frame.height + taggedLabel.frame.height
            
            scrollView.contentSize = CGSize(
                width: scrollView.bounds.width,
                height: totalContentHeight
            )
        } else {
            taggedLabel.pin
                .bottom(view.pin.safeArea)
                .horizontally()
                .marginHorizontal(20)
                .marginBottom(30)
                .sizeToFit(.width)
            
            getCodeButton.pin
                .bottom(to: taggedLabel.edge.top)
                .horizontally()
                .marginBottom(20)
                .marginHorizontal(20)
                .height(50)
            
            scrollView.contentSize = CGSize(
                width: scrollView.bounds.width,
                height: contentHeight
            )
        }
    }
}
// MARK: - Notification Center

extension AuthorizationViewController {
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    private func keyboardShow(notification: NSNotification) {
        isKeyboardShow = true
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        scrollView.contentInset.bottom = keyboardSize.height
        scrollView.scrollIndicatorInsets = .init(top: .zero,
                                                 left: .zero,
                                                 bottom: keyboardSize.height,
                                                 right: .zero)
        animateLayout()
    }
    
    @objc
    private func keyboardHide() {
        isKeyboardShow = false
        scrollView.contentInset.bottom = .zero
        scrollView.verticalScrollIndicatorInsets = .zero
        animateLayout()
    }
    
    private func animateLayout() {
        UIView.animate(withDuration: 0.8) {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - TaggedLabelDelegate

extension AuthorizationViewController: TaggedLabelDelegate {
    func personalDataDidTapped() {
        coordinator.openPDFViewController(pdfFile: .personalData)
    }
    
    func privacyPolicyDidTapper() {
        coordinator.openPDFViewController(pdfFile:.privacyPolicy)
    }
}
