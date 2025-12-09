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
        AuthorizationViewController(coordinator: Coordinator.shared)
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
    
    static func makeCalendarViewController() -> UIViewController {
        let calendarViewController = CalendarViewController()
        return calendarViewController
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
}
