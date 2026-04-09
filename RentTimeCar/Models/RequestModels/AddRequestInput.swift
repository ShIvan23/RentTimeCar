//
//  AddRequestInput.swift
//  RentTimeCar
//

import Foundation

struct AddRequestInput: Encodable {
    // MARK: - Required
    let clientIntegrationId: String
    let clientPhone: String
    let rentFromTime: String
    let rentToTime: String
    let tarifId: String
    let autoId: String

    // MARK: - Optional
    let deliveryAddress: String?
    let returnAddress: String?
    let requestSource: String?
    let servicesList: [ServicePriceItem]?
    let clientComment: String?
    let promoCode: String?
}

struct ServicePriceItem: Encodable {
    let code: String
    let basePrice: Int
    let count: Double
}
