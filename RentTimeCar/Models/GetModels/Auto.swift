//
//  Autos.swift
//  RentTimeCar
//
//  Created by Ekaterina Volobueva on 01.08.2025.
//

import Foundation

struct Auto: Decodable {
    let title: String
    let files: [File]
    let defaultPriceWithDiscountSt: Int
    let marka: String
    let motorPower: Int
    let classAuto: String
    
    enum CodingKeys: String, CodingKey {
        case files = "Files"
        case title = "Title"
        case defaultPriceWithDiscountSt = "DefaultPriceWithDiscountSt"
        case marka = "Marka"
        case motorPower = "ModInfoPowerLSValue"
        case classAuto = "AutoClassTitle"
    }
}

struct File: Decodable {
    let url: String?
}
