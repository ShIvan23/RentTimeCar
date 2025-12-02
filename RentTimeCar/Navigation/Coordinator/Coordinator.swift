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
    func openFilterViewController()
    func openCalendarViewController()
    func openDetailAutoCar(model: Auto)
    func openFullImageViewController(with image: String)
    func openYandexMapController()
    func openSearchAddressViewController(delegate: SearchAddressViewControllerDelegate)
    func popViewController()
}

final class Coordinator: NSObject, ICoordinator {
    var navigationController: UINavigationController?
    private lazy var transition = ImageTransition()
    
    static let shared = Coordinator()
    private override init() {}
    
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
    
    func openFilterViewController() {
        let filterViewController = Builder.makeFilterViewController()
        navigationController?.pushViewController(filterViewController, animated: true)
    }
    
    func openCalendarViewController() {
        let calendarViewController = Builder.makeCalendarViewController()
        navigationController?.pushViewController(calendarViewController, animated: true)
    }
    
    func openDetailAutoCar(model: Auto) {
        let detailViewController = Builder.makeDetailViewController(with: model)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func openFullImageViewController(with image: String) {
        let fullImageViewController = Builder.makeFullImageViewController(with: image)
        fullImageViewController.modalPresentationStyle = .custom
        fullImageViewController.transitioningDelegate = self
        navigationController?.present(fullImageViewController, animated: true)
    }
    
    func openYandexMapController() {
        let yandexMapController = Builder.makeYandexMapViewController()
        navigationController?.pushViewController(yandexMapController, animated: true)
    }
    
    func openSearchAddressViewController(delegate: SearchAddressViewControllerDelegate) {
        let searchAddressViewController = Builder.makeSearchAddressViewController(delegate: delegate)
        navigationController?.pushViewController(searchAddressViewController, animated: true)
    }
    
    func popViewController() {
        navigationController?.popViewController(animated: true)
    }
}

extension Coordinator: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        return transition
    }
}
