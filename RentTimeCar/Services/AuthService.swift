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

enum AuthState: String {
    case needAuthorize
    case needRegister
    case onCheck
    case fullAccess
    case banned
}

// Сервис, который хранит информацию залогинился ли клиент через смс в приложении
final class AuthService {
    static let shared = AuthService()

    // MARK: - Internal Properties

    private(set) var authState: AuthState
    private(set) var integrationId: String?

    // MARK: - Private Properties

    private let userDefaults = UserDefaults.standard
    private var observers = NSHashTable<AnyObject>.weakObjects()
    private let rentApiFacade: IRentApiFacade = RentApiFacade()
    private var phoneNumber: String?

    // MARK: - Init

    private init() {
        // debug clear
//        userDefaults.set(nil, forKey: .authStateKey)
//        userDefaults.set(nil, forKey: .phoneNumberKey)
//        userDefaults.set(nil, forKey: .isRegisteredKey)
//        userDefaults.set(nil, forKey: .integrationIdKey)

        phoneNumber = userDefaults.string(forKey: .phoneNumberKey)
        integrationId = userDefaults.string(forKey: .integrationIdKey)
        if let authState = AuthState(rawValue: userDefaults.string(forKey: .authStateKey) ?? "") {
            print("+++ authState id UD = \(authState)")
            self.authState = authState
        } else {
            print("+++ NOOOO authState id UD. needAuthorize")
            authState = .needAuthorize
        }

        guard authState != .needAuthorize else { return }
        
        checkRegistration(needInvoke: false)
    }

    // MARK: - Internal Methods

    func addObserver(_ observer: AuthServiceObserver) {
        if !observers.contains(observer) {
            observers.add(observer)
        }
    }

    func saveState(authState: AuthState) {
        self.authState = authState
        userDefaults.set(authState.rawValue, forKey: .authStateKey)

        // Если пользователь авторизовался через смс, то нужно проверить, заведена ли карточка на клиента и есть ли его доки в системе
        checkRegistration()
    }

    func savePhoneNumber(_ phoneNumber: String) {
        self.phoneNumber = phoneNumber
        userDefaults.set(phoneNumber, forKey: .phoneNumberKey)
    }

    // MARK: - Private Methods

    private func checkRegistration(needInvoke: Bool = true) {
        guard let phoneNumber else { return }
        rentApiFacade.getClients(with: phoneNumber) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(clients):
                print("+++ success clients = \(clients)")
                let integrationId = clients.result?.clients.first?.integrationId
                self.integrationId = integrationId
                userDefaults.set(integrationId, forKey: .integrationIdKey)
                handleClientRegistration(with: clients.result, needInvoke: needInvoke)
            case let .failure(error):
                debugPrint("+++ error = \(error)")
            }
        }
    }
    
    private func handleClientRegistration(with model: Clients?, needInvoke: Bool) {
        guard let client = model?.clients.first else { return }
        
        defer {
            if needInvoke {
                invokeAllSubscribers()
            }
        }
        
        if client.isBanned {
            authState = .banned
            return
        }
        
        if client.name.isEmptyFirstAndLastNames || client.passport.isEmptySerriesAndNumber {
            let allReadyOnCheck = authState == .onCheck
            if allReadyOnCheck {
                authState = .onCheck
                return
            } else {
                authState = .needRegister
                return
            }
        }
        
        authState = .fullAccess
    }

    private func invokeAllSubscribers() {
        DispatchQueue.main.async {
            self.observers.allObjects.forEach {
                guard let authServiceObserver = $0 as? AuthServiceObserver else { return }
                authServiceObserver.post(state: self.authState)
            }
        }
    }
}

private extension String {
    static let authStateKey = "authStateKey"
    static let phoneNumberKey = "phoneNumberKey"
    static let integrationIdKey = "integrationIdKey"
}
