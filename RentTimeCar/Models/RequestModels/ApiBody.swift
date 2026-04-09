//
//  ApiBody.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 30.07.2025.
//

import Foundation

struct ApiBody<T: Encodable>: Encodable {
    let apiKey: String
    let apiVersion: String
    let method: String
    let parameters: T
    
    enum CodingKeys: String, CodingKey {
        case apiKey = "ApiKey"
        case apiVersion = "ApiVersion"
        case method = "Method"
        case parameters = "Parameters"
    }
}
