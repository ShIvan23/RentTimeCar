//
//  YukassaWebViewController.swift
//  RentTimeCar
//

import UIKit
import WebKit

final class YukassaWebViewController: UIViewController {

    // MARK: - Properties

    private let coordinator: ICoordinator
    private let amount: Int
    private let paymentDescription: String
    private let rentApiFacade: IRentApiFacade = RentApiFacade()

    private lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView.navigationDelegate = self
        return webView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Init

    init(coordinator: ICoordinator, amount: Int, description: String) {
        self.coordinator = coordinator
        self.amount = amount
        self.paymentDescription = description
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Оплата"
        view.backgroundColor = .white
        setupViews()
        createPayment()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
        activityIndicator.center = view.center
    }

    // MARK: - Private

    private func setupViews() {
        view.addSubview(webView)
        view.addSubview(activityIndicator)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Закрыть",
            style: .plain,
            target: self,
            action: #selector(handleClose)
        )
    }

    private func createPayment() {
        activityIndicator.startAnimating()
        let phone = AuthService.shared.phoneNumber ?? ""
        rentApiFacade.createYukassaPayment(amount: amount, description: paymentDescription, phone: phone) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case let .success(response):
                    guard let url = URL(string: response.confirmationUrl) else {
                        self.activityIndicator.stopAnimating()
                        self.handlePaymentFail()
                        return
                    }
                    self.webView.load(URLRequest(url: url))
                case let .failure(error):
                    print("+++ error createPayment = \(error)")
                    self.activityIndicator.stopAnimating()
                    self.handlePaymentFail()
                }
            }
        }
    }

    private func handlePaymentSuccess() {
        coordinator.openPaymentSuccessBottomSheet { [weak self] in
            self?.coordinator.popToRootViewController()
        }
    }

    private func handlePaymentFail() {
        coordinator.openPaymentFailBottomSheet { [weak self] in
            self?.coordinator.popViewController()
        }
    }

    @objc private func handleClose() {
        coordinator.openPaymentCancelConfirmationBottomSheet { [weak self] in
            self?.handlePaymentFail()
        }
    }
}

// MARK: - WKNavigationDelegate

extension YukassaWebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let urlString = navigationAction.request.url?.absoluteString else {
            decisionHandler(.allow)
            return
        }

        // ЮKassa перенаправляет на return_url после успешной оплаты.
        if urlString.hasPrefix(YukassaService.returnURL) {
            decisionHandler(.cancel)
            handlePaymentSuccess()
            return
        }

        // Перенаправление на fail URL (отмена / ошибка).
        if urlString.hasPrefix(YukassaService.failURL) {
            decisionHandler(.cancel)
            handlePaymentFail()
            return
        }

        decisionHandler(.allow)
    }
}
