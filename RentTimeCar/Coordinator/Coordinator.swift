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
}

final class Coordinator: ICoordinator {
    var navigationController: UINavigationController?
    
    func openAuthorization() {
        let authorizationViewController = Builder.makeAuthorizationViewController()
        navigationController?.pushViewController(authorizationViewController, animated: true)
    }
}
