//
//  RentApiFacade.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 30.07.2025.
//

import Foundation
import UIKit

protocol IRentApiFacade {
    func getClients(with phoneNumber: String, completion: @escaping (Result<ApiResult<Clients>, Error>) -> Void)
    func addClient(with phoneNumber: String, completion: @escaping (Result<ApiResult<Client>, Error>) -> Void)
    func getAutos(completion: @escaping (Result<ApiResult<[Auto]>, Error>) -> Void)
    func searchAuto(with: SearchAutoInput, completion: @escaping (Result<ApiResult<[Auto]>, Error>) -> Void)
    func getContacts(completion: @escaping (Result<[Contact], Error>) -> Void)
    func getOfficeAddress(completion: @escaping (Result<OfficeAddress, Error>) -> Void)
    func getFilterPrams(completion: @escaping (Result<ApiResult<GetFilterParams>, Error>) -> Void)
    func getSmsCode(with phoneNumber: String, code: String, completion: @escaping (Result<SmsModel, Error>) -> Void)
    func uploadImages(
        _ images: [UIImage],
        clientIntegrationId: String,
        onProgress: @escaping (Double) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func addRequest(with input: AddRequestInput, completion: @escaping (Result<ApiResult<EmptyResponse>, Error>) -> Void)
    func getClientRequests(clientIntegrationId: String, completion: @escaping (Result<ApiResult<ClientRequestsResponse>, Error>) -> Void)
    func getContractMoneyInfo(clientIntegrationId: String, objectId: Int64, completion: @escaping (Result<ApiResult<ContractMoneyInfoResponse>, Error>) -> Void)
    func getContractMoneyInfo(clientIntegrationId: String, objectId: Int, completion: @escaping (Result<ApiResult<ContractMoneyInfoResponse>, Error>) -> Void)
    func getClientContracts(clientIntegrationId: String, completion: @escaping (Result<ApiResult<ContractsResponse>, Error>) -> Void)
    func getClientFines(clientIntegrationId: String, completion: @escaping (Result<ApiResult<FinesResponse>, Error>) -> Void)
    func getAutoCalendar(with input: GetAutoCalendarInput, completion: @escaping (Result<[AutoCalendar], Error>) -> Void)
    func getActInfo(clientIntegrationId: String, objectId: String, objectDescriptorLong: Int, completion: @escaping (Result<ApiResult<ActInfoResponse>, Error>) -> Void)
    func getActInfo(clientIntegrationId: String, objectId: Int, objectDescriptorLong: Int, completion: @escaping (Result<ApiResult<ActInfoResponse>, Error>) -> Void)
    func createYukassaPayment(amount: Int, description: String, phone: String, completion: @escaping (Result<YookassaPaymentResponse, Error>) -> Void)
}

final class RentApiFacade: IRentApiFacade {
    private let requestManager = RequestManagerV2()
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
    
    func getContacts(completion: @escaping (Result<[Contact], Error>) -> Void) {
        guard let request = requestManager.getContacts() else { return }
        networkManager.fetch(request: request, completion: completion)
    }

    func getOfficeAddress(completion: @escaping (Result<OfficeAddress, Error>) -> Void) {
        guard let request = requestManager.getOfficeAddress() else { return }
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

    func uploadImages(
        _ images: [UIImage],
        clientIntegrationId: String,
        onProgress: @escaping (Double) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let (request, body) = requestManager.uploadImages(images, clientIntegrationId: clientIntegrationId) else { return }
        networkManager.upload(
            request: request,
            body: body,
            onProgress: onProgress
        ) { (result: Result<EmptyResponse, Error>) in
            completion(result.map { _ in })
        }
    }

    func addRequest(with input: AddRequestInput, completion: @escaping (Result<ApiResult<EmptyResponse>, Error>) -> Void) {
        guard let request = requestManager.addRequest(with: input) else { return }
        networkManager.fetch(request: request, completion: completion)
    }

    func getContractMoneyInfo(clientIntegrationId: String, objectId: Int, completion: @escaping (Result<ApiResult<ContractMoneyInfoResponse>, Error>) -> Void) {
        guard let request = requestManager.getContractMoneyInfo(clientIntegrationId: clientIntegrationId, objectId: objectId) else { return }
        networkManager.fetch(request: request, completion: completion)
    }

    func getClientContracts(clientIntegrationId: String, completion: @escaping (Result<ApiResult<ContractsResponse>, Error>) -> Void) {
        guard let request = requestManager.getClientContracts(clientIntegrationId: clientIntegrationId) else { return }
        networkManager.fetch(request: request, completion: completion)
    }

    func getClientFines(clientIntegrationId: String, completion: @escaping (Result<ApiResult<FinesResponse>, Error>) -> Void) {
        guard let request = requestManager.getClientFines(clientIntegrationId: clientIntegrationId) else { return }
        networkManager.fetch(request: request, completion: completion)
    }

    func getAutoCalendar(with input: GetAutoCalendarInput, completion: @escaping (Result<[AutoCalendar], Error>) -> Void) {
        guard let request = requestManager.getAutoCalendar(with: input) else { return }
        networkManager.fetch(request: request, completion: completion)
    }

    func getActInfo(clientIntegrationId: String, objectId: String, objectDescriptorLong: Int, completion: @escaping (Result<ApiResult<ActInfoResponse>, Error>) -> Void) {
    func getActInfo(clientIntegrationId: String, objectId: Int, objectDescriptorLong: Int, completion: @escaping (Result<ApiResult<ActInfoResponse>, Error>) -> Void) {
        guard let request = requestManager.getActInfo(clientIntegrationId: clientIntegrationId, objectId: objectId, objectDescriptorLong: objectDescriptorLong) else { return }
        networkManager.fetch(request: request, completion: completion)
    }

    func createYukassaPayment(amount: Int, description: String, phone: String, completion: @escaping (Result<YookassaPaymentResponse, Error>) -> Void) {
        let input = YookassaPaymentInput(amount: amount, description: description, phone: phone)
        guard let request = YukassaService.shared.makeCreatePaymentRequest(input: input) else { return }
        networkManager.fetch(request: request, completion: completion)
    }
}
