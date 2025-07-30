//
//  Builder.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 30.07.2025.
//

import UIKit

final class Builder {
    static func makeMainViewController() -> UIViewController {
        let coordinator = Coordinator()
        let rentFacadeApi = RentApiFacade()
        let controller = MainViewController(
            coordinator: coordinator,
            rentApiFacade: rentFacadeApi
        )
        let navigationController = UINavigationController(rootViewController: controller)
        coordinator.navigationController = navigationController
        return navigationController
    }
    
    static func makeAuthorizationViewController() -> UIViewController {
        AuthorizationViewController()
    }
}
