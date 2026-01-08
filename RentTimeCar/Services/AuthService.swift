//
//  AuthService.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 07.01.2026.
//

import Foundation

protocol AuthServiceObserver: AnyObject {
    func post(isAuthorized: Bool)
}

final class AuthService {
    static let shared = AuthService()

    // MARK: - Internal Properties

    private(set) var isAuthorized: Bool

    // MARK: - Private Properties

    private let userDefaults = UserDefaults.standard
    private var observers = NSHashTable<AnyObject>.weakObjects()

    // MARK: - Init

    private init() {
        // debug clear
//        userDefaults.set(false, forKey: .isAuthorizedKey)

        isAuthorized = userDefaults.bool(forKey: .isAuthorizedKey)
    }

    // MARK: - Internal Methods

    func addObserver(_ observer: AuthServiceObserver) {
        if !observers.contains(observer) {
            observers.add(observer)
        }
    }

    func saveState(isAuthorized: Bool) {
        self.isAuthorized = isAuthorized
        userDefaults.set(isAuthorized, forKey: .isAuthorizedKey)
        observers.allObjects.forEach {
            guard let authServiceObserver = $0 as? AuthServiceObserver else { return }
            authServiceObserver.post(isAuthorized: isAuthorized)
        }
    }
}

private extension String {
    static let isAuthorizedKey = "isAuthorizedKey"
}
