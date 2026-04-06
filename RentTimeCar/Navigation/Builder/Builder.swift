//
//  Builder.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 30.07.2025.
//

import UIKit

final class Builder {
    
    static func makeMainViewController() -> UIViewController {
        let coordinator = Coordinator.shared
        let rentApiFacade = RentApiFacade()
        let controller = MainViewController(
            coordinator: coordinator,
            rentApiFacade: rentApiFacade
        )
        let navigationController = UINavigationController(rootViewController: controller)
        coordinator.navigationController = navigationController
        return navigationController
    }
    
    static func makeAuthorizationViewController() -> UIViewController {
        let rentApiFacade = RentApiFacade()
        return AuthorizationViewController(
            coordinator: Coordinator.shared,
            rentApiFacade: rentApiFacade
        )
    }
    
    static func makePDFViewController(pdfFile: PDFViewController.PDFFile) -> UIViewController {
        PDFViewController(pdfFile: pdfFile)
    }
    
    static func makeFilterViewController() -> UIViewController {
        let rentApiFacade = RentApiFacade()
        let filterViewController = FilterViewController(
            coordinator: Coordinator.shared,
            rentApiFacade: rentApiFacade
        )
        return filterViewController
    }
    
    static func makeCalendarViewController(autoId: String? = nil) -> UIViewController {
        CalendarViewController(autoId: autoId, coordinator: Coordinator.shared)
    }
    
    static func makeDetailViewController(with model: Auto) -> UIViewController {
        let coordinator = Coordinator.shared
        let detailViewController = DetailAutoViewController(autoModel: model, coordinator: coordinator)
        return detailViewController
    }
    
    static func makeFullImageViewController(with image: String) -> UIViewController {
        FullImageViewController(image: image)
    }
    
    static func makeYandexMapViewController() -> UIViewController {
        let coordinator = Coordinator.shared
        return YandexMapViewController(coordinator: coordinator)
    }
    
    static func makeSearchAddressViewController(delegate: SearchAddressViewControllerDelegate) -> UIViewController {
        let coordinator = Coordinator.shared
        return SearchAddressViewController(
            coordinator: coordinator,
            delegate: delegate
        )
    }
    
    static func makeBottomSheetViewController(type: BottomSheetType) -> UIViewController {
        let coordinator = Coordinator.shared
        let bottomSheetFilterView = BottomSheetFilterViewController(
            type: type,
            coordinator: coordinator
        )

        if let sheet = bottomSheetFilterView.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        return bottomSheetFilterView
    }

    static func makeDetailOrderOptionsViewController() -> UIViewController {
        let coordinator = Coordinator.shared
        let detailOrderOptionsViewController = DetailOrderOptionsViewController(coordinator: coordinator)
        return detailOrderOptionsViewController
    }

    static func makeDetailOrderInfoBottomSheetViewController(type: DetailOrderOptionModel.CellType) -> UIViewController {
        let coordinator = Coordinator.shared
        let detailOrderInfoBottomSheetViewController = DetailOrderInfoBottomSheetViewController(
            type: type,
        coordinator: coordinator
        )
        if let sheet = detailOrderInfoBottomSheetViewController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        return detailOrderInfoBottomSheetViewController
    }

    static func makeEnterSmsCodeViewController(phoneNumber: String, checkCode: String) -> UIViewController {
        let coordinator = Coordinator.shared
        return EnterSmsCodeViewController(
            coordinator: coordinator,
            phoneNumber: phoneNumber,
            checkCode: checkCode
        )
    }

    static func makeContactsBottomSheetViewController() -> UIViewController {
        let coordinator = Coordinator.shared
        let contactsBottomSheetViewController = ContactsViewController(
            coordinator: coordinator
        )
        if let sheet = contactsBottomSheetViewController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        return contactsBottomSheetViewController
    }

    static func makeOrderConfirmViewController() -> UIViewController {
        let coordinator = Coordinator.shared
        let orderConfirmViewController = OrderConfirmViewController(coordinator: coordinator)
        return orderConfirmViewController
    }
    
    static func makeRentSummaryViewController() -> UIViewController {
        let coordinator = Coordinator.shared
        let rentSummaryViewController = RentSummaryViewController(coordinator: coordinator)
        return rentSummaryViewController
    }

    static func makeRegistrationViewController() -> UIViewController {
        let coordinator = Coordinator.shared
        let cameraPermissionService = CameraPermissionService()
        let rentApiFacade = RentApiFacade()
        let registrationViewController = RegistrationViewController(
            coordinator: coordinator,
            cameraPermissionService: cameraPermissionService,
            rentApiFacade: rentApiFacade
        )
        return registrationViewController
    }

    static func makeCameraViewController(photoStep: RegistrationPhotoStep) -> UIViewController {
        let coordinator = Coordinator.shared
        let cameraViewController = CameraViewController(coordinator: coordinator, photoStep: photoStep)
        return cameraViewController
    }

    static func makeInfoBottomSheetViewController() -> UIViewController {
        let coordinator = Coordinator.shared
        let model = InfoBottomSheetModel.makeDeniedCameraPermissionModel {
            coordinator.openSettingsApp()
        }
        return makeInfoBottomSheetViewController(model: model)
    }

    static func makeInfoBottomSheetViewController(model: InfoBottomSheetModel) -> UIViewController {
        let infoBottomSheetViewController = InfoBottomSheetViewController(model: model)
        if let sheet = infoBottomSheetViewController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        return infoBottomSheetViewController
    }

    static func makePaymentSuccessBottomSheet(onDismiss: @escaping () -> Void) -> UIViewController {
        let model = InfoBottomSheetModel.makePaymentSuccessModel(onConfirm: onDismiss)
        let vc = InfoBottomSheetViewController(model: model)
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        return vc
    }

    static func makePaymentFailBottomSheet(onDismiss: @escaping () -> Void) -> UIViewController {
        let model = InfoBottomSheetModel.makePaymentFailModel(onConfirm: onDismiss)
        let vc = InfoBottomSheetViewController(model: model)
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        return vc
    }

    static func makePaymentCancelConfirmationBottomSheet(onConfirm: @escaping () -> Void) -> UIViewController {
        let model = InfoBottomSheetModel.makePaymentCancelConfirmationModel(onConfirm: onConfirm)
        let vc = InfoBottomSheetViewController(model: model)
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        return vc
    }

    static func makeRobokassaWebViewController(paymentURL: URL, invId: Int) -> RobokassaWebViewController {
        RobokassaWebViewController(coordinator: Coordinator.shared, paymentURL: paymentURL, invId: invId)
    }

    static func makeYukassaWebViewController(amount: Int, description: String) -> YukassaWebViewController {
        YukassaWebViewController(coordinator: Coordinator.shared, amount: amount, description: description)
    }

    static func makeSuccessPhotoViewController(image: UIImage, photoStep: RegistrationPhotoStep) -> UIViewController {
        let coordinator = Coordinator.shared
        let successPhotoViewController = SuccessPhotoViewController(
            coordinator: coordinator,
            image: image,
            photoStep: photoStep
        )
        return successPhotoViewController
    }

    static func makeClientItemsViewController(mode: ClientItemsViewController.Mode) -> UIViewController {
        let coordinator = Coordinator.shared
        let rentApiFacade = RentApiFacade()
        return ClientItemsViewController(mode: mode, coordinator: coordinator, rentApiFacade: rentApiFacade)
    }
}
