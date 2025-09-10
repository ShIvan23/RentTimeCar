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
    }
    
    private let pdfFile: PDFFile
    
    init(pdfFile: PDFFile) {
        self.pdfFile = pdfFile
        super.init(nibName: nil, bundle: nil)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
    }
    
    private func setupView() {
        let pdfView = PDFView(frame: view.bounds)
        view.addSubview(pdfView)
        pdfView.autoScales = true
        let url: URL?
        switch pdfFile {
        case .personalData:
            url = Bundle.main.url(forResource: "Personal data", withExtension: "pdf")
        case .privacyPolicy:
            url = Bundle.main.url(forResource: "Privacy policy", withExtension: "pdf")
        }
        guard let url else {
            assertionFailure("No url for pdf file")
            return
        }
        pdfView.document = PDFDocument(url: url)
    }
}
