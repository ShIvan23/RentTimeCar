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
    func openBottomSheet(type: BottomSheetType)
    func openDetailOrderOptionsViewController()
    func openDetailOrderInfoBottomSheetViewController(type: DetailOrderOptionModel.CellType)
    func openEnterSmsCodeViewController(phoneNumber: String, checkCode: String)
    func openContactsViewController()
    func openOrderConfirmViewController()
    func popViewController()
    func dismissViewController()
    func popToRootViewController()
    func openAnotherApplication(url: URL)
    func openRentSummaryViewController()
}

final class Coordinator: NSObject, ICoordinator {
    var navigationController: UINavigationController?
    private lazy var transition = ImageTransition()
    
    static let shared = Coordinator()
    private override init() {}
    
    func openAuthorization() {
        let authorizationViewController = Builder.makeAuthorizationViewController()
        navigationController?.pushViewController(authorizationViewController, animated: true)
    }
    
    func openPDFViewController(pdfFile: PDFViewController.PDFFile) {
        let pdfViewController = Builder.makePDFViewController(pdfFile: pdfFile)
        navigationController?.pushViewController(pdfViewController, animated: true)
    }
    
    func openFilterViewController() {
        let filterViewController = Builder.makeFilterViewController()
        navigationController?.pushViewController(filterViewController, animated: true)
        navigationController?.isNavigationBarHidden = false
    }
    
    func openCalendarViewController() {
        let calendarViewController = Builder.makeCalendarViewController()
        navigationController?.pushViewController(calendarViewController, animated: true)
        navigationController?.isNavigationBarHidden = false
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
    
    func openBottomSheet(type: BottomSheetType) {
        let bottomSheetViewController = Builder.makeBottomSheetViewController(type: type)
        navigationController?.present(bottomSheetViewController, animated: true)
    }

    func openDetailOrderOptionsViewController() {
        let detailOrderOptionsViewController = Builder.makeDetailOrderOptionsViewController()
        detailOrderOptionsViewController.title = "Дополнительные опции"
        navigationController?.pushViewController(detailOrderOptionsViewController, animated: true)
    }

    func openDetailOrderInfoBottomSheetViewController(type: DetailOrderOptionModel.CellType) {
        let detailOrderInfoBottomSheetViewController = Builder.makeDetailOrderInfoBottomSheetViewController(type: type)
        navigationController?.present(detailOrderInfoBottomSheetViewController, animated: true)
    }

    func openEnterSmsCodeViewController(phoneNumber: String, checkCode: String) {
        let enterSmsCodeViewController = Builder.makeEnterSmsCodeViewController(
            phoneNumber: phoneNumber,
            checkCode: checkCode
        )
        navigationController?.pushViewController(enterSmsCodeViewController, animated: true)
    }

    func openContactsViewController() {
        let contactsViewController = Builder.makeContactsBottomSheetViewController()
        navigationController?.present(contactsViewController, animated: true)
    }

    func openOrderConfirmViewController() {
        let orderConfirmViewController = Builder.makeOrderConfirmViewController()
        navigationController?.pushViewController(orderConfirmViewController, animated: true)
    }

    func popViewController() {
        navigationController?.popViewController(animated: true)
    }

    func dismissViewController() {
        navigationController?.topViewController?.dismiss(animated: true)
    }

    func popToRootViewController() {
        navigationController?.popToRootViewController(animated: true)
    }

    func openAnotherApplication(url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func openRentSummaryViewController() {
        let rentSummaryViewController = Builder.makeRentSummaryViewController()
        rentSummaryViewController.title = "Стоимость"
        navigationController?.pushViewController(rentSummaryViewController, animated: true)
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
