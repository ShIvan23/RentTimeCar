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
    func createContract(with input: CreateContractInput, completion: @escaping (Result<ApiResult<SimpleOutputDto>, Error>) -> Void)
    func getContractMoneyInfo(clientIntegrationId: String, objectId: Int, completion: @escaping (Result<ApiResult<ContractMoneyInfoResponse>, Error>) -> Void)
    func getClientContracts(clientIntegrationId: String, completion: @escaping (Result<ApiResult<ContractsResponse>, Error>) -> Void)
    func getClientFines(clientIntegrationId: String, completion: @escaping (Result<ApiResult<FinesResponse>, Error>) -> Void)
    func getAutoCalendar(with input: GetAutoCalendarInput, completion: @escaping (Result<[AutoCalendar], Error>) -> Void)
    func getAutoUsedIntervals(with input: GetAutoUsedIntervalsInput, completion: @escaping (Result<ApiResult<[UsedInterval]>, Error>) -> Void)
    func getActSignState(clientIntegrationId: String, objectId: Int, objectDescriptorLong: Int, completion: @escaping (Result<ActSignStateResponse, Error>) -> Void)
    func acceptAct(clientIntegrationId: String, objectId: Int, signDate: Date?, completion: @escaping (Result<ApiResult<EmptyResponse>, Error>) -> Void)
    func getActInfo(clientIntegrationId: String, objectId: Int, objectDescriptorLong: Int, contractNumber: String, contractDate: String, renterName: String, renterPassport: String, renterPhone: String, carInfo: String, completion: @escaping (Result<Data, Error>) -> Void)
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

    func createContract(with input: CreateContractInput, completion: @escaping (Result<ApiResult<SimpleOutputDto>, Error>) -> Void) {
        guard let request = requestManager.createContract(with: input) else { return }
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

    func getAutoUsedIntervals(with input: GetAutoUsedIntervalsInput, completion: @escaping (Result<ApiResult<[UsedInterval]>, Error>) -> Void) {
        guard let request = requestManager.getAutoUsedIntervals(with: input) else { return }
        networkManager.fetch(request: request, completion: completion)
    }

    func getActSignState(clientIntegrationId: String, objectId: Int, objectDescriptorLong: Int, completion: @escaping (Result<ActSignStateResponse, Error>) -> Void) {
        guard let request = requestManager.getActSignState(clientIntegrationId: clientIntegrationId, objectId: objectId, objectDescriptorLong: objectDescriptorLong) else { return }
        networkManager.fetch(request: request, completion: completion)
    }

    func acceptAct(clientIntegrationId: String, objectId: Int, signDate: Date?, completion: @escaping (Result<ApiResult<EmptyResponse>, Error>) -> Void) {
        guard let request = requestManager.acceptAct(clientIntegrationId: clientIntegrationId, objectId: objectId, signDate: signDate) else { return }
        networkManager.fetch(request: request, completion: completion)
    }

    func getActInfo(clientIntegrationId: String, objectId: Int, objectDescriptorLong: Int, contractNumber: String, contractDate: String, renterName: String, renterPassport: String, renterPhone: String, carInfo: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let request = requestManager.getActInfo(
            clientIntegrationId: clientIntegrationId,
            objectId: objectId,
            objectDescriptorLong: objectDescriptorLong,
            contractNumber: contractNumber,
            contractDate: contractDate,
            renterName: renterName,
            renterPassport: renterPassport,
            renterPhone: renterPhone,
            carInfo: carInfo
        ) else { return }
        networkManager.fetchData(request: request, completion: completion)
    }

    func createYukassaPayment(amount: Int, description: String, phone: String, completion: @escaping (Result<YookassaPaymentResponse, Error>) -> Void) {
        let input = YookassaPaymentInput(amount: amount, description: description, phone: phone)
        guard let request = YukassaService.shared.makeCreatePaymentRequest(input: input) else { return }
        networkManager.fetch(request: request, completion: completion)
    }
}
