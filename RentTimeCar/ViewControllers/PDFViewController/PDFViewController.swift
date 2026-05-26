//
//  PDFViewController.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 01.08.2025.
//

import PDFKit
import UIKit

final class PDFViewController: UIViewController {
    enum PDFFile {
        case personalData
        case privacyPolicy
        case data(Data)
        case url(URL)
    }

    // MARK: - UI

    private let pdfView = PDFView()
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()
    private let errorLabel = Label(
        text: "Не удалось загрузить документ.\nПроверьте подключение к интернету.",
        numberOfLines: 0,
        fontSize: 16,
        textColor: .secondaryTextColor,
        textAlignment: .center
    )
    private let retryButton = MainButton(title: "Повторить")

    // MARK: - Private Properties

    private let pdfFile: PDFFile

    // MARK: - Init

    init(pdfFile: PDFFile) {
        self.pdfFile = pdfFile
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        navigationController?.isNavigationBarHidden = false
        setupView()
        loadPDF()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pdfView.frame = view.bounds
        activityIndicator.center = view.center

        retryButton.pin
            .bottom()
            .horizontally()
            .marginHorizontal(16)
            .marginBottom(view.safeAreaInsets.bottom + 16)
            .height(50)

        errorLabel.pin
            .above(of: retryButton)
            .horizontally()
            .marginHorizontal(32)
            .marginBottom(24)
            .sizeToFit(.width)
    }

    // MARK: - Private Methods

    private func setupView() {
        pdfView.autoScales = true
        view.addSubview(pdfView)
        view.addSubview(activityIndicator)
        view.addSubview(errorLabel)
        view.addSubview(retryButton)
        errorLabel.isHidden = true
        retryButton.isHidden = true
    }

    private func loadPDF() {
        switch pdfFile {
        case .personalData:
            if let url = Bundle.main.url(forResource: "Personal data", withExtension: "pdf") {
                pdfView.document = PDFDocument(url: url)
            }
        case .privacyPolicy:
            if let url = Bundle.main.url(forResource: "Privacy policy", withExtension: "pdf") {
                pdfView.document = PDFDocument(url: url)
            }
        case .data(let data):
            pdfView.document = PDFDocument(data: data)
        case .url(let remoteUrl):
            loadRemotePDF(from: remoteUrl)
        }
    }

    private func loadRemotePDF(from url: URL) {
        errorLabel.isHidden = true
        retryButton.isHidden = true
        activityIndicator.startAnimating()
        URLSession.shared.dataTask(with: url) { [weak self] data, response, _ in
            DispatchQueue.main.async {
                guard let self else { return }
                self.activityIndicator.stopAnimating()
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                if statusCode == 200, let data, let document = PDFDocument(data: data) {
                    self.pdfView.document = document
                } else {
                    self.showError(retryUrl: url)
                }
            }
        }.resume()
    }

    private func showError(retryUrl: URL) {
        errorLabel.isHidden = false
        retryButton.isHidden = false
        retryButton.action = { [weak self] in
            self?.loadRemotePDF(from: retryUrl)
        }
        view.setNeedsLayout()
    }
}
