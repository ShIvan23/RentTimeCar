//
//  Coordinator.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 30.07.2025.
//

import UIKit

protocol ICoordinator {
    var navigationController: UINavigationController? { get set }
    func openAuthorization()
    func openPDFViewController(pdfFile: PDFViewController.PDFFile)
}

final class Coordinator: ICoordinator {
    var navigationController: UINavigationController?
    
    static let shared = Coordinator()
    private init() {}
    
    func openAuthorization() {
        let authorizationViewController = Builder.makeAuthorizationViewController()
        navigationController?.pushViewController(authorizationViewController, animated: true)
        authorizationViewController.navigationController?.navigationBar.isHidden = false
    }
    
    func openPDFViewController(pdfFile: PDFViewController.PDFFile) {
        let pdfViewController = Builder.makePDFViewController(pdfFile: pdfFile)
        navigationController?.pushViewController(pdfViewController, animated: true)
        pdfViewController.navigationController?.navigationBar.isHidden = false
    }
}
