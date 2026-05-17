//
//  PayContractSumResponse.swift
//  RentTimeCar
//

import Foundation

struct PayContractSumResponse: Decodable {
    let operation: [MoneyOperation]

    enum CodingKeys: String, CodingKey {
        case operation = "Operation"
    }
}
