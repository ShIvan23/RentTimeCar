//
//  GetFilterParams.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 14.10.2025.
//

import Foundation

struct GetFilterParams: Decodable {
    let brands: [DictValueDTO]
    
    enum CodingKeys: String, CodingKey {
        case brands = "Brands"
    }
}

struct DictValueDTO: Decodable {
    let id: Int // тут везде 0 приходит
    let title: String
    let code: String // тут везде пустая строка приходит
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case title = "Title"
        case code = "Code"
    }
}
