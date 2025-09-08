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
}
