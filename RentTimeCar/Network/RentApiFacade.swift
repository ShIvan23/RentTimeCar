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
    func getAutos(completion: @escaping (Result<ApiResult<[Auto]>, Error>) -> Void)
    func searchAuto(with: SearchAutoInput, completion: @escaping (Result<ApiResult<[Auto]>, Error>) -> Void)
    func getFilterPrams(completion: @escaping (Result<ApiResult<GetFilterParams>, Error>) -> Void)
    func getSmsCode(with phoneNumber: String, code: String, completion: @escaping (Result<SmsModel, Error>) -> Void)
}

final class RentApiFacade: IRentApiFacade {
    private let requestManager = RequestManager()
    private let networkManager = NetworkManager()

    // Запрос делается без + перед 7
    func getClients(with phoneNumber: String, completion: @escaping (Result<ApiResult<Clients>, Error>) -> Void) {
        guard let request = requestManager.getClients(with: phoneNumber) else { return }
        networkManager.fetch(request: request, completion: completion)
    }
    
    func addClient(with phoneNumber: String, completion: @escaping (Result<ApiResult<Client>, Error>) -> Void) {
        guard let request = requestManager.addClient(with: phoneNumber) else { return }
        networkManager.fetch(request: request, completion: completion)
    }
    
    func getAutos(completion: @escaping (Result<ApiResult<[Auto]>, Error>) -> Void) {
        guard let request = requestManager.getAutos() else { return }
        networkManager.fetch(request: request, completion: completion)
    }
    
    func searchAuto(with: SearchAutoInput, completion: @escaping (Result<ApiResult<[Auto]>, Error>) -> Void) {
        guard let request = requestManager.searchAuto(with: with) else { return }
        networkManager.fetch(request: request, completion: completion)
    }
    
    func getFilterPrams(completion: @escaping (Result<ApiResult<GetFilterParams>, Error>) -> Void) {
        guard let request = requestManager.getFiltersParams() else { return }
        networkManager.fetch(request: request, completion: completion)
    }

    func getSmsCode(with phoneNumber: String, code: String, completion: @escaping (Result<SmsModel, Error>) -> Void) {
        guard let request = requestManager.getSmsRequest(for: phoneNumber, code: code) else { return }
        networkManager.fetch(request: request, completion: completion)
    }
}
