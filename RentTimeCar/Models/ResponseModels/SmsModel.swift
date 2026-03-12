//
//  SmsModel.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 12.12.2025.
//

import Foundation

struct SmsModel: Decodable {
    let status: String
    let statusCode: Int
    let balance: Double

    enum CodingKeys: String, CodingKey {
        case status
        case statusCode = "status_code"
        case balance
    }
}
