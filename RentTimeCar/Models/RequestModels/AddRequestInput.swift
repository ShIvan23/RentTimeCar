//
//  AddRequestInput.swift
//  RentTimeCar
//

import Foundation

struct AddRequestInput: Encodable {
    // MARK: - Required
    let documentsUrls: [String]
    let requestDealTypeId: String
    let requestFilialId: String
    let rentFilialFrom: String
    let rentFromTime: String
    let rentToTime: String
    let tarifId: String
    let autoId: String

    // MARK: - Optional
    let clientIntegrationId: String?
    let clientPhone: String?
    let rentFilialTo: String?
    let deliveryAddress: String?
    let returnAddress: String?
    let requestSource: String?
    let createContract: Bool?
    let contractCompanyId: String?
    let confirmed: Bool?
    let servicesList: [ServicePriceItem]?
    let clientComment: String?
    let promoCode: String?
}

struct ServicePriceItem: Encodable {
    let code: String
    let basePrice: Int
    let count: Double
}
