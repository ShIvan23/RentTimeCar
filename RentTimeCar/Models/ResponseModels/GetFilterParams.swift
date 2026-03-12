//
//  GetFilterParams.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 14.10.2025.
//

import Foundation

struct GetFilterParams: Decodable {
    let autoClassCodes: [DictValueDTO]

    enum CodingKeys: String, CodingKey {
        case autoClassCodes = "AutoClassCodes"
    }
}

struct DictValueDTO: Decodable {
    let title: String
    let code: String
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case code = "Code"
    }
}
