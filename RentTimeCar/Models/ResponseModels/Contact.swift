//
//  Contact.swift
//  RentTimeCar
//

import Foundation

struct Contact: Decodable {
    let title: String
    let phoneNumber: String
    let type: ContactType

    enum ContactType: String, Decodable {
        case phone
        case telegram
        case whatsapp
        case max
    }
}
