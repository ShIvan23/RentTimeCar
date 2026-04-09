//
//  AppDelegate.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 28.07.2025.
//

import CoreLocation
import YandexMapsMobile
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupYandexMaps()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
    
    // MARK: - Private Methods
    
    private func setupYandexMaps() {
        YMKMapKit.setApiKey("562570cd-9220-4b25-bca2-be3259c844d5")
        YMKMapKit.sharedInstance()
    }
}

