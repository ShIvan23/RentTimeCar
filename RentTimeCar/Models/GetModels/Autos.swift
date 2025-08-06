//
//  Autos.swift
//  RentTimeCar
//
//  Created by Ekaterina Volobueva on 01.08.2025.
//

import Foundation

struct Autos: Decodable {
    let title: String
    let files: [File]
    let defaultPriceWithDiscountSt: Int
    
    enum CodingKeys: String, CodingKey {
        case files = "Files"
        case title = "Title"
        case defaultPriceWithDiscountSt = "DefaultPriceWithDiscountSt"
    }
}

struct File: Decodable {
    let url: String?

}
