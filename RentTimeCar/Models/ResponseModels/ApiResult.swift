//
//  ApiResult.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 30.07.2025.
//

import Foundation

struct ApiResult<T: Decodable>: Decodable {
    let result: T?
    let errors: [ApiError]?
    let method: String
    
    enum CodingKeys: String, CodingKey {
        case result = "Result"
        case errors = "Errors"
        case method = "Method"
    }
}

struct ApiError: Decodable {
    let code: Int
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code = "Code"
        case message = "Message"
    }
}
