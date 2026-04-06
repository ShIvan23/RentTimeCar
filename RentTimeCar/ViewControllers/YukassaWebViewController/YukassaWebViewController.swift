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
                    self.activityIndicator.stopAnimating()
                    self.handlePaymentFail()
                }
            }
        }
    }

    private func handlePaymentSuccess() {
        sendAddRequest(retries: 3)
    }

    private func sendAddRequest(retries: Int) {
        guard let input = makeAddRequestInput() else {
            handlePaymentFail()
            return
        }
        rentApiFacade.addRequest(with: input) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                DispatchQueue.main.async { self.openSuccessBottomSheet() }
            case .failure:
                if retries > 0 {
                    self.sendAddRequest(retries: retries - 1)
                } else {
                    DispatchQueue.main.async { self.handlePaymentFail() }
                }
            }
        }
    }

    private func makeAddRequestInput() -> AddRequestInput? {
        let order = OrderConfirmService.shared
        let auth = AuthService.shared
        guard
            let integrationId = auth.client?.integrationId,
            let phone = auth.phoneNumber,
            let auto = order.auto,
            let rentFrom = FilterService.shared.selectedDates.first?.convertDateToString(),
            let rentTo = FilterService.shared.selectedDates.last?.convertDateToString()
        else { return nil }

        let services = order.selectedServices.map {
            ServicePriceItem(code: $0.serviceTitle, basePrice: $0.effectivePrice, count: 1)
        }

        return AddRequestInput(
            clientIntegrationId: integrationId,
            clientPhone: phone,
            rentFromTime: rentFrom,
            rentToTime: rentTo,
            tarifId: order.tarifId,
            autoId: String(auto.itemID),
            deliveryAddress: order.deliveryAddress.isEmpty ? nil : order.deliveryAddress,
            returnAddress: order.returnAddress.isEmpty ? nil : order.returnAddress,
            requestSource: nil,
            servicesList: services.isEmpty ? nil : services,
            clientComment: nil,
            promoCode: nil
        )
    }

    private func openSuccessBottomSheet() {
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
