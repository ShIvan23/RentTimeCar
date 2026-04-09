//
//  OfficeAddress.swift
//  RentTimeCar
//

import Foundation

struct OfficeAddress: Decodable {
    let latitude: Double
    let longitude: Double
    let address: String
    let workingHours: String
}
