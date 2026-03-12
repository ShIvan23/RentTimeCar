//
//  Client.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 30.07.2025.
//

import Foundation

struct Clients: Decodable {
    let clients: [Client]
    
    enum CodingKeys: String, CodingKey {
        case clients = "Clients"
    }
}

struct Client: Decodable {
    let name: Name
    let integrationId: String

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case integrationId = "IntegrationId"
    }
}

extension Client {
    struct Name: Decodable {
        let firstName: String
        let lastName: String
        
        // non decodable property
        // TODO: - Уточнить у Стаса могут ли быть пустые эти поля у клиента, который прошел авторизацию с документами.
        var isEmptyFirstAndLastNames: Bool {
            firstName.isEmpty && lastName.isEmpty
        }
        
        enum CodingKeys: String, CodingKey {
            case firstName = "FirstName"
            case lastName = "LastName"
        }
    }
}
