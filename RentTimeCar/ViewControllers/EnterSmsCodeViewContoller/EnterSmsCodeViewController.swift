//
//  EnterSmsCodeViewController.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 16.12.2025.
//

import UIKit

final class EnterSmsCodeViewController: UIViewController, ToastViewShowable {

    // MARK: - ToastViewShowable

    var showingToast: ToastView?

    // MARK: - Private Properties

    private let checkCode: String
    private var isKeyboardShow = false
    private var keyBoardHeight: CGFloat = .zero
    private var timer: Timer?
    private var timeMinute = 10 {
        didSet {
            guard timeMinute == .zero else { return }
            showRetryCodeButton()
        }
    }

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let label = Label(fontSize: 14, textColor: .secondaryTextColor)
    private let enterCodeLabel = Label(text: "Введите код")
    private let retryLabel = Label()
    private lazy var enterCodeView = EnterCodeView(delegate: self)
    private let retryButton = MainButton(title: "Отправить код еще раз")

    // MARK: Init

    init(
        phoneNumber: String,
        checkCode: String
    ) {
        self.checkCode = checkCode
        super.init(nibName: nil, bundle: nil)
        label.text = "Отправили Вам смс на номер \(phoneNumber)"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life Cycle

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
        invalidateTimer()
        removeKeyboardObservers()
    }

    // MARK: - Private Methods

    private func setupView() {
        view.backgroundColor = .black
        view.addSubview(scrollView)
        scrollView.addSubviews([label, enterCodeLabel, enterCodeView, retryLabel, retryButton])
        setupTimer()
        retryButton.isHidden = true
        addTapGesture() 
    }

    private func addTapGesture() {
        view.addTapGestureClosure { [weak self] in
            self?.view.endEditing(true)
        }
    }

    private func showRetryCodeButton() {
        invalidateTimer()
        retryLabel.isHidden = true
        retryButton.isHidden = false
        view.setNeedsLayout()
    }

    private func setupTimer() {
        let timer = Timer(timeInterval: 1.0, repeats: true, block: { _ in
            self.timeMinute -= 1
            self.retryLabel.text = .retryText + String(self.timeMinute)
        })
        timer.tolerance = 0.1
        self.timer = timer
        RunLoop.current.add(timer, forMode: .common)
    }

    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func performLayout() {
        scrollView.pin
            .all(view.pin.safeArea)

        label.pin
            .top(isKeyboardShow ? 60 : 160)
            .horizontally()
            .marginHorizontal(20)
            .sizeToFit(.width)

        enterCodeLabel.pin
            .below(of: label)
            .horizontally()
            .marginTop(16)
            .marginHorizontal(20)
            .sizeToFit(.width)

        enterCodeView.pin
            .below(of: enterCodeLabel)
            .horizontally()
            .marginTop(16)
            .marginHorizontal(20)
            .height(60)

        if !retryLabel.isHidden {
            retryLabel.pin
                .bottom()
                .horizontally()
                .marginBottom(isKeyboardShow ? keyBoardHeight : view.pin.safeArea.bottom)
                .marginHorizontal(16)
                .sizeToFit(.width)
        }

        if !retryButton.isHidden {
            retryButton.pin
                .bottom()
                .horizontally()
                .marginBottom(isKeyboardShow ? keyBoardHeight : view.pin.safeArea.bottom)
                .marginHorizontal(16)
                .height(50)
        }
    }
}

// MARK: - EnterCodeViewDelegate

extension EnterSmsCodeViewController: EnterCodeViewDelegate {
    func validateCode(_ code: String) {
        guard checkCode == code else { return showToast(with: "Код из смс введен не верно")}
        NotificationCenter.default.post(name: .authorizationDidEnd, object: nil)
    }
}

// MARK: - Notification Center

extension EnterSmsCodeViewController {
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
        keyBoardHeight = keyboardSize.height
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

private extension String {
    static let retryText = "Выслать код можно еще раз через "
}
