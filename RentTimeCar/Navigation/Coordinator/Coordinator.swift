//
//  Coordinator.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 30.07.2025.
//

import UIKit

enum ICoordinatorController {
    case registration
}

protocol ICoordinator {
    var navigationController: UINavigationController? { get set }
    func openAuthorization()
    func openPDFViewController(pdfFile: PDFViewController.PDFFile)
    func openFilterViewController()
    func openCalendarViewController(autoId: String?)
    func openDetailAutoCar(model: Auto)
    func openFullImageViewController(images: [String], initialIndex: Int)
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
    func openRobokassaPayment(amount: Int, invId: Int, description: String, onSuccess: @escaping (Int) -> Void, onFail: @escaping () -> Void)
    func openYukassaPayment(amount: Int, description: String)
    func openPaymentSuccessBottomSheet(onDismiss: @escaping () -> Void)
    func openPaymentFailBottomSheet(onDismiss: @escaping () -> Void)
    func openPaymentCancelConfirmationBottomSheet(onConfirm: @escaping () -> Void)
    func openRegistrationViewController()
    func openCameraViewController(photoStep: RegistrationPhotoStep)
    func openSettingsApp()
    func openInfoBottomSheetViewController()
    func openInfoBottomSheetViewController(model: InfoBottomSheetModel)
    func openSuccessPhotoViewController(image: UIImage, photoStep: RegistrationPhotoStep)
    func popToViewController(_ controller: ICoordinatorController)
    func openClientRequestsViewController()
    func openClientFinesViewController()
    func openRentDetailViewController(request: ClientRequest)
}

extension ICoordinator {
    func openCalendarViewController() {
        openCalendarViewController(autoId: nil)
    }
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
    
    func openCalendarViewController(autoId: String? = nil) {
        let calendarViewController = Builder.makeCalendarViewController(autoId: autoId)
        navigationController?.pushViewController(calendarViewController, animated: true)
        navigationController?.isNavigationBarHidden = false
    }
    
    func openDetailAutoCar(model: Auto) {
        let detailViewController = Builder.makeDetailViewController(with: model)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func openFullImageViewController(images: [String], initialIndex: Int) {
        let fullImageViewController = Builder.makeFullImageViewController(images: images, initialIndex: initialIndex)
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

    func openRobokassaPayment(amount: Int, invId: Int, description: String, onSuccess: @escaping (Int) -> Void, onFail: @escaping () -> Void) {
        guard let url = RobokassaService.shared.buildPaymentURL(amount: amount, invId: invId, description: description) else { return }
        let paymentVC = Builder.makeRobokassaWebViewController(paymentURL: url, invId: invId)
        paymentVC.onSuccess = onSuccess
        paymentVC.onFail = onFail
        paymentVC.title = "Оплата"
        navigationController?.pushViewController(paymentVC, animated: true)
    }

    func openYukassaPayment(amount: Int, description: String) {
        let paymentVC = Builder.makeYukassaWebViewController(amount: amount, description: description)
        navigationController?.pushViewController(paymentVC, animated: true)
    }

    func openPaymentSuccessBottomSheet(onDismiss: @escaping () -> Void) {
        let vc = Builder.makePaymentSuccessBottomSheet(onDismiss: onDismiss)
        navigationController?.present(vc, animated: true)
    }

    func openPaymentFailBottomSheet(onDismiss: @escaping () -> Void) {
        let vc = Builder.makePaymentFailBottomSheet(onDismiss: onDismiss)
        navigationController?.present(vc, animated: true)
    }

    func openPaymentCancelConfirmationBottomSheet(onConfirm: @escaping () -> Void) {
        let vc = Builder.makePaymentCancelConfirmationBottomSheet(onConfirm: onConfirm)
        navigationController?.topViewController?.present(vc, animated: true)
    }

    func openRegistrationViewController() {
        let registrationViewController = Builder.makeRegistrationViewController()
        registrationViewController.title = "Регистрация"
        navigationController?.pushViewController(registrationViewController, animated: true)
        navigationController?.isNavigationBarHidden = false
    }

    func openCameraViewController(photoStep: RegistrationPhotoStep) {
        let cameraViewController = Builder.makeCameraViewController(photoStep: photoStep)
        navigationController?.pushViewController(cameraViewController, animated: true)
    }

    func openSettingsApp() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    func openInfoBottomSheetViewController() {
        let infoBottomSheetViewController = Builder.makeInfoBottomSheetViewController()
        navigationController?.present(infoBottomSheetViewController, animated: true)
    }

    func openInfoBottomSheetViewController(model: InfoBottomSheetModel) {
        let infoBottomSheetViewController = Builder.makeInfoBottomSheetViewController(model: model)
        navigationController?.present(infoBottomSheetViewController, animated: true)
    }

    func openSuccessPhotoViewController(image: UIImage, photoStep: RegistrationPhotoStep) {
        let successPhotoViewController = Builder.makeSuccessPhotoViewController(image: image, photoStep: photoStep)
        navigationController?.pushViewController(successPhotoViewController, animated: true)
    }

    func popToViewController(_ controller: ICoordinatorController) {
        switch controller {
        case .registration:
            guard let registrationViewController = navigationController?.viewControllers.first(where: { $0 is RegistrationViewController }) else { return }
            navigationController?.popToViewController(registrationViewController, animated: true)
        }
    }

    func openClientRequestsViewController() {
        let vc = Builder.makeClientItemsViewController(mode: .rents)
        vc.title = "Мои аренды"
        navigationController?.pushViewController(vc, animated: true)
        navigationController?.isNavigationBarHidden = false
    }

    func openClientFinesViewController() {
        let vc = Builder.makeClientItemsViewController(mode: .fines)
        vc.title = "Мои штрафы"
        navigationController?.pushViewController(vc, animated: true)
        navigationController?.isNavigationBarHidden = false
    }

    func openRentDetailViewController(request: ClientRequest) {
        let vc = Builder.makeRentDetailViewController(request: request)
        navigationController?.pushViewController(vc, animated: true)
        navigationController?.isNavigationBarHidden = false
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
