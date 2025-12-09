//
//  SearchAutoInput.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 14.10.2025.
//

import Foundation

struct SearchAutoInput: Encodable {
    let dateFrom: String
    let dateTo: String
    let brands: [String]
    let defaultPriceFrom: Int
    let defaultPriceTo: Int
    let autoClasses: [String]
    let powerMin: Int
    let powerMax: Int

    enum CodingKeys: String, CodingKey {
        case dateFrom = "DateFrom"
        case dateTo = "DateTo"
        case brands = "Brands"
        case defaultPriceFrom = "DefaultPriceFrom"
        case defaultPriceTo = "DefaultPriceTo"
        case autoClasses = "AutoClassCodes"
        case powerMin = "ModInfoPowerLSMin"
        case powerMax = "ModInfoPowerLSMax"
    }
}
