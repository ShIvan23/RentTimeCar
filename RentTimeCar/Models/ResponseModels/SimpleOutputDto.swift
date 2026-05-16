//
//  SimpleOutputDto.swift
//  RentTimeCar
//

import Foundation

struct SimpleOutputDto: Decodable {
    let longParamValue: Int?
    let longParamValue2: Int?
    let stringParamValue: String?
    let boolParamValue: Bool?

    enum CodingKeys: String, CodingKey {
        case longParamValue = "LongParamValue"
        case longParamValue2 = "LongParamValue2"
        case stringParamValue = "StringParamValue"
        case boolParamValue = "BoolParamValue"
    }
}
