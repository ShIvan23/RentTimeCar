//
//  RobokassaWebViewController.swift
//  RentTimeCar
//

import UIKit
import WebKit

final class RobokassaWebViewController: UIViewController {

    // MARK: - Properties
    var onSuccess: ((Int) -> Void)?
    var onFail: (() -> Void)?

    private let paymentURL: URL
    private let invId: Int

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
    init(paymentURL: URL, invId: Int) {
        self.paymentURL = paymentURL
        self.invId = invId
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
        showCancelConfirmation()
    }

    private func showCancelConfirmation() {
        let alert = UIAlertController(
            title: "Отменить оплату?",
            message: "Вы уверены, что хотите прервать оплату?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel))
        alert.addAction(UIAlertAction(title: "Да, отменить", style: .destructive) { [weak self] _ in
            self?.onFail?()
        })
        present(alert, animated: true)
    }
}

// MARK: - WKNavigationDelegate
extension RobokassaWebViewController: WKNavigationDelegate {

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

        if urlString.hasPrefix(RobokassaService.successURL) {
            decisionHandler(.cancel)
            onSuccess?(invId)
            return
        }

        if urlString.hasPrefix(RobokassaService.failURL) {
            decisionHandler(.cancel)
            onFail?()
            return
        }

        decisionHandler(.allow)
    }
}
