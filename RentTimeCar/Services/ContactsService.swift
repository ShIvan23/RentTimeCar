//
//  ContactsService.swift
//  RentTimeCar
//

import Foundation

final class ContactsService {
    static let shared = ContactsService()

    private(set) var cachedContacts: [Contact]?
    private let rentApiFacade: IRentApiFacade = RentApiFacade()

    private init() {}

    func prefetch() {
        guard cachedContacts == nil else { return }
        rentApiFacade.getContacts { [weak self] result in
            if case let .success(contacts) = result {
                self?.cachedContacts = contacts
            }
        }
    }

    func getContacts(completion: @escaping (Result<[Contact], Error>) -> Void) {
        if let cached = cachedContacts {
            completion(.success(cached))
            return
        }
        rentApiFacade.getContacts { [weak self] result in
            if case let .success(contacts) = result {
                self?.cachedContacts = contacts
            }
            completion(result)
        }
    }
}
