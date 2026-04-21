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

protocol AuthServiceErrorDelegate: AnyObject {
    func handleAuthError()
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
    private(set) var client: Client?
    private(set) var phoneNumber: String?

    // MARK: - Private Properties

    private let userDefaults = UserDefaults.standard
    private var observers = NSHashTable<AnyObject>.weakObjects()
    private var errorObservers = NSHashTable<AnyObject>.weakObjects()
    private let rentApiFacade: IRentApiFacade = RentApiFacade()

    // MARK: - Init

    private init() {
        phoneNumber = userDefaults.string(forKey: .phoneNumberKey)
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
    
    func addErrorObserver(_ observer: AuthServiceErrorDelegate) {
        if !errorObservers.contains(observer) {
            errorObservers.add(observer)
        }
    }

    func saveState(authState: AuthState) {
        self.authState = authState
        userDefaults.set(authState.rawValue, forKey: .authStateKey)
        invokeAllSubscribers()
    }

    func refreshAuthState() {
        checkRegistration()
    }

    func savePhoneNumber(_ phoneNumber: String) {
        self.phoneNumber = phoneNumber
        userDefaults.set(phoneNumber, forKey: .phoneNumberKey)
        checkRegistration()
    }

    func logout() {
        authState = .needAuthorize
        client = nil
        phoneNumber = nil
        userDefaults.set(AuthState.needAuthorize.rawValue, forKey: .authStateKey)
        userDefaults.removeObject(forKey: .phoneNumberKey)
        invokeAllSubscribers()
    }

    // MARK: - Private Methods

    private func checkRegistration(needInvoke: Bool = true) {
        guard let phoneNumber else { return }
        rentApiFacade.getClients(with: phoneNumber) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(clients):
                if clients.result?.clients.isEmpty == true {
                    addClient(with: phoneNumber)
                } else {
                    self.client = clients.result?.clients.first
                    handleClientRegistration(with: client, needInvoke: needInvoke)
                }
            case .failure:
                invokeAllErrorSubscribers()
            }
        }
    }
    
    private func addClient(with phoneNumber: String) {
        rentApiFacade.addClient(with: phoneNumber) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(client):
                self.client = client.result
                saveState(authState: .needRegister)
            case .failure:
                invokeAllErrorSubscribers()
            }
        }
    }
    
    private func handleClientRegistration(with model: Client?, needInvoke: Bool) {
        guard let client = model else { return }
        
        defer {
            userDefaults.set(authState.rawValue, forKey: .authStateKey)
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
    
    private func invokeAllErrorSubscribers() {
        DispatchQueue.main.async {
            self.errorObservers.allObjects.forEach {
                guard let authServiceErrorObserver = $0 as? AuthServiceErrorDelegate else { return }
                authServiceErrorObserver.handleAuthError()
            }
        }
    }
}

private extension String {
    static let authStateKey = "authStateKey"
    static let phoneNumberKey = "phoneNumberKey"
}
