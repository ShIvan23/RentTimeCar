//
//  AuthService.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 07.01.2026.
//

import Foundation

protocol AuthServiceObserver: AnyObject {
    /// Метод, который уведомляет подписчиков, что состояние пользователя изменилось
    func post(state: AuthState)
}

enum AuthState {
    case needAuthorize
    case needRegister
    case onCheck
    case fullAccess
}

// Сервис, который хранит информацию залогинился ли клиент через смс в приложении
final class AuthService {
    static let shared = AuthService()

    // MARK: - Internal Properties

    var isAuthorized: Bool {
        authState != .needAuthorize
    }

    private(set) var authState: AuthState

    // MARK: - Private Properties

    private let userDefaults = UserDefaults.standard
    private var observers = NSHashTable<AnyObject>.weakObjects()
    private let rentApiFacade: IRentApiFacade = RentApiFacade()
    private var phoneNumber: String?
    private var isRegistered: Bool

    // MARK: - Init

    private init() {
        // debug clear
//        userDefaults.set(false, forKey: .isAuthorizedKey)

        let isAuthorized = userDefaults.bool(forKey: .isAuthorizedKey)
        phoneNumber = userDefaults.string(forKey: .phoneNumberKey)
        isRegistered = userDefaults.bool(forKey: .isRegisteredKey)

        guard isAuthorized else {
            authState = .needAuthorize
            return
        }

        authState = .fullAccess
        print("+++ authState = \(authState)")
    }

    // MARK: - Internal Methods

    func addObserver(_ observer: AuthServiceObserver) {
        if !observers.contains(observer) {
            observers.add(observer)
        }
    }

    func saveState(authState: AuthState) {
        let isAuthorized = authState != .needAuthorize
        userDefaults.set(isAuthorized, forKey: .isAuthorizedKey)
        guard isAuthorized else {
            // Если пользователь вышел из профиля, то надо всех уведомить, что необходимо залогиниться через смс
            self.authState = .needAuthorize
            invokeAllSubscribers()
            return
        }

        // Если пользователь уже имеет подтвержденный аккаунт, то не нужно идти в сеть
        // TODO: - Узнать у Стаса, могут ли они блокировать учетки в CRM
        guard !isRegistered else {
            self.authState = .needRegister
            invokeAllSubscribers()
            return
        }

        // Если пользователь авторизовался через смс, то нужно проверить, заведена ли карточка на клиента и есть ли его доки в системе
        checkRegistration { [weak self] isRegistered in
            guard let self else { return }
            userDefaults.set(isRegistered, forKey: .isRegisteredKey)
            print("+++ isRegistered = \(isRegistered)")
            self.authState = isRegistered ? .fullAccess : .onCheck
        }
    }

    func savePhoneNumber(_ phoneNumber: String) {
        userDefaults.set(phoneNumber, forKey: .phoneNumberKey)
    }

    // MARK: - Private Methods

    private func checkRegistration(completion: @escaping (Bool) -> Void) {
        guard let phoneNumber else { return completion(false) }
        rentApiFacade.getClients(with: phoneNumber) { result in
            switch result {
            case let .success(clients):
                completion(clients.result?.clients.isEmpty == false)
            case let .failure(error):
                debugPrint("+++ error = \(error)")
                completion(false)
            }
        }
    }

    private func invokeAllSubscribers() {
        observers.allObjects.forEach {
            guard let authServiceObserver = $0 as? AuthServiceObserver else { return }
            authServiceObserver.post(state: authState)
        }
    }
}

private extension String {
    static let isAuthorizedKey = "isAuthorizedKey"
    static let isRegisteredKey = "isRegisteredKey"
    static let phoneNumberKey = "phoneNumberKey"
}
