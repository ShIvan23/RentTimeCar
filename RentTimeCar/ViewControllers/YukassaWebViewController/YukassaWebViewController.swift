//
//  YukassaWebViewController.swift
//  RentTimeCar
//

import UIKit
import WebKit

final class YukassaWebViewController: UIViewController {

    // MARK: - Properties

    var onSuccess: (() -> Void)?
    var onFail: (() -> Void)?

    private let coordinator: ICoordinator
    private let paymentURL: URL

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

    init(coordinator: ICoordinator, paymentURL: URL) {
        self.coordinator = coordinator
        self.paymentURL = paymentURL
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
        loadPaymentPage()
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

    private func loadPaymentPage() {
        webView.load(URLRequest(url: paymentURL))
    }

    @objc private func handleClose() {
        coordinator.openPaymentCancelConfirmationBottomSheet { [weak self] in
            self?.onFail?()
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
            onSuccess?()
            return
        }

        // Перенаправление на fail URL (отмена / ошибка).
        if urlString.hasPrefix(YukassaService.failURL) {
            decisionHandler(.cancel)
            onFail?()
            return
        }

        decisionHandler(.allow)
    }
}
