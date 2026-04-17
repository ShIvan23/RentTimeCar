//
//  SceneDelegate.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 28.07.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        window?.overrideUserInterfaceStyle = .dark
        window?.makeKeyAndVisible()
        makeNavBarAppearance()
        let rentApiFacade = RentApiFacade()
        let splash = SplashViewController(rentApiFacade: rentApiFacade) { [weak self] result in
            guard let self else { return }
            let main = Builder.makeMainViewController(preloadedAutos: result)
            UIView.transition(with: self.window!, duration: 0.3, options: .transitionCrossDissolve) {
                self.window?.rootViewController = main
            }
        }
        window?.rootViewController = splash
    }
    
    private func makeNavBarAppearance() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        navigationBarAppearance.backgroundColor = .mainBackground
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
}
