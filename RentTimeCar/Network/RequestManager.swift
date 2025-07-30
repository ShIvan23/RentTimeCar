//
//  RequestManager.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 29.07.2025.
//

import Foundation

final class RequestManager {
    enum Method: String {
        case post = "POST"
    }
    private let baseURL = URL(string: "http://xl4.xlombard.ru/684a/handlers/IntegrationApi/JsonRpc.ashx")
    private let apiKey = "fUOyeGf77Nl4ErEmFCKhQiJTwlVSgplH"
    private let baseHeader = ["content-type": "application/json"]
    private let encoder = JSONEncoder()
    
    func getClients(with phoneNumber: String) -> URLRequest? {
        guard let baseURL else {
            assertionFailure("Invalid baseURL")
            return nil
        }
        var request = makeBaseUrl(url: baseURL)
        let getClient = GetClient(phoneNumber: phoneNumber)
        let apiBody = ApiBody(
            apiKey: apiKey,
            apiVersion: "0",
            method: "GetClients",
            parameters: getClient
        )
        let data = try? encoder.encode(apiBody)
        request.httpBody = data
        return request
    }
    
    func addClient(with phoneNumber: String) -> URLRequest? {
        guard let baseURL else {
            assertionFailure("Invalid baseURL")
            return nil
        }
        var request = makeBaseUrl(url: baseURL)
        let addClient = GetClient(phoneNumber: phoneNumber)
        let apiBody = ApiBody(
            apiKey: apiKey,
            apiVersion: "0",
            method: "AddClient",
            parameters: addClient
        )
        let data = try? encoder.encode(apiBody)
        request.httpBody = data
        return request
    }
    
    private func makeBaseUrl(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = Method.post.rawValue
        request.allHTTPHeaderFields = baseHeader
        return request
    }
}
