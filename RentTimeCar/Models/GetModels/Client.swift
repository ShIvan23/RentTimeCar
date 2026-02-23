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

    enum CodingKeys: String, CodingKey {
        case name = "Name"
    }
}

extension Client {
    struct Name: Decodable {

    }
}
