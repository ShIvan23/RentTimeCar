//
//  RentApiFacade.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 30.07.2025.
//

import Foundation

protocol IRentApiFacade {
    func getClients(with phoneNumber: String, completion: @escaping (Result<ApiResult<Clients>, Error>) -> Void)
    func addClient(with phoneNumber: String, completion: @escaping (Result<ApiResult<Client>, Error>) -> Void)
}

final class RentApiFacade: IRentApiFacade {
    private let requestManager = RequestManager()
    private let networkManager = NetworkManager()
    
    func getClients(with phoneNumber: String, completion: @escaping (Result<ApiResult<Clients>, Error>) -> Void) {
        guard let request = requestManager.getClients(with: phoneNumber) else { return }
        networkManager.fetch(request: request, completion: completion)
    }
    
    func addClient(with phoneNumber: String, completion: @escaping (Result<ApiResult<Client>, Error>) -> Void) {
        guard let request = requestManager.addClient(with: phoneNumber) else { return }
        networkManager.fetch(request: request, completion: completion)
    }
}
