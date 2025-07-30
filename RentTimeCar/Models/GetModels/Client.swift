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
    
}
