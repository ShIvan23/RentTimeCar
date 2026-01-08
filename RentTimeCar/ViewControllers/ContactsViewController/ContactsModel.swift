//
//  ContactsModel.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 08.01.2026.
//

import Foundation

struct ContactsModel {
    let title: String
    let type: ContactsModelType

    enum ContactsModelType {
        case call
        case telegram
        case whatsApp
    }
}

extension ContactsModel {
    static func makeModel() -> [ContactsModel] {
        return [
            ContactsModel(
                title: "Позвонить",
                type: .call
            ),
            ContactsModel(
                title: "Написать в Telegram",
                type: .telegram
            ),
            ContactsModel(
                title: "Написать в WhatsApp",
                type: .whatsApp
            )
        ]
    }
}
