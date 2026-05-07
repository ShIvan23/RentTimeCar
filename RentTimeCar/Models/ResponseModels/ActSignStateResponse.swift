//
//  ActSignStateResponse.swift
//  RentTimeCar
//

import Foundation

struct ActSignStateResponse: Decodable {
    let actSignState: Int
    let actSignStateLabel: String
    let needsSignature: Bool

    enum CodingKeys: String, CodingKey {
        case actSignState = "actSignState"
        case actSignStateLabel = "actSignStateLabel"
        case needsSignature = "needsSignature"
    }
}
