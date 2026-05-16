//
//  CreateContractInput.swift
//  RentTimeCar
//

import Foundation

struct CreateContractInput: Encodable {
    // MARK: - Required
    let rentFromTime: String
    let rentToTime: String
    let tarifId: String
    let autoId: String

    // MARK: - Optional
    let clientIntegrationId: String?
    let clientPhone: String?
    let clientComment: String?
}
