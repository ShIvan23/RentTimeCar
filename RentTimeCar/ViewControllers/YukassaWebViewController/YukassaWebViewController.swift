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
    private let contractId: Int?
    private let rentApiFacade: IRentApiFacade = RentApiFacade()
    private let authService: AuthService = .shared

    private var paymentId: String?
    private var pollingTimer: Timer?
    private var pollingElapsed: TimeInterval = 0
    private static let pollingInterval: TimeInterval = 3
    private static let pollingTimeout: TimeInterval = 600

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

    init(coordinator: ICoordinator, amount: Int, description: String, contractId: Int?) {
        self.coordinator = coordinator
        self.amount = amount
        self.paymentDescription = description
        self.contractId = contractId
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
                    self.paymentId = response.paymentId
                    self.startPolling()
                    self.webView.load(URLRequest(url: url))
                case .failure:
                    self.activityIndicator.stopAnimating()
                    self.handlePaymentFail()
                }
            }
        }
    }

    // MARK: - Polling

    private func startPolling() {
        pollingElapsed = 0
        pollingTimer = Timer.scheduledTimer(withTimeInterval: Self.pollingInterval, repeats: true) { [weak self] _ in
            self?.pollPaymentStatus()
        }
    }

    private func stopPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }

    private func pollPaymentStatus() {
        guard let paymentId else { return }
        pollingElapsed += Self.pollingInterval
        if pollingElapsed >= Self.pollingTimeout {
            stopPolling()
            return
        }
        rentApiFacade.getPaymentStatus(paymentId: paymentId) { [weak self] result in
            guard let self else { return }
            guard case let .success(response) = result else { return }
            DispatchQueue.main.async {
                switch response.status {
                case .succeeded:
                    self.stopPolling()
                    self.handlePaymentSuccess()
                case .canceled:
                    self.stopPolling()
                    self.handlePaymentFail()
                case .pending:
                    break
                }
            }
        }
    }

    private func handlePaymentSuccess() {
        stopPolling()
        guard
            let integrationId = authService.client?.integrationId,
            let contractId
        else {
            openSuccessBottomSheet()
            return
        }
        rentApiFacade.payContractSum(
            clientIntegrationId: integrationId,
            contractId: String(contractId),
            sum: Decimal(amount)
        ) { [weak self] result in
            switch result {
            case .success:
                break
            case .failure:
                break
            }
            DispatchQueue.main.async { self?.openSuccessBottomSheet() }
        }
    }

    private func openSuccessBottomSheet() {
        coordinator.openPaymentSuccessBottomSheet { [weak self] in
            self?.coordinator.popToRootViewController()
        }
    }

    private func handlePaymentFail() {
        stopPolling()
        coordinator.openPaymentFailBottomSheet { [weak self] in
            self?.coordinator.popViewController()
        }
    }

    @objc private func handleClose() {
        stopPolling()
        coordinator.openPaymentCancelConfirmationBottomSheet { [weak self] in
            self?.coordinator.popViewController()
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
