//
//  ActInfoResponse.swift
//  RentTimeCar
//

import Foundation

struct ActInfoResponse: Decodable {
    let id: Int
    let actType: Int
    let mileage: Int
    let fuelCount: Int
    let bodyStatus: Int
    let salonStatus: Int
    let truncStatus: Int
    let hasNewDamages: Bool
    let plannedTime: String
    let clientTime: String
    let actState: Int
    let userId: Int
    let userName: String?
    let filialId: Int
    let filialName: String?
    let actSignState: Int
    let images: [ActImage]?
    let bodySchemeCode: String?
    let damageTypes: String?
    let repairTypes: String?
    let damages: String?

    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case actType = "ActType"
        case mileage = "Mileage"
        case fuelCount = "FuelCount"
        case bodyStatus = "BodyStatus"
        case salonStatus = "SalonStatus"
        case truncStatus = "TruncStatus"
        case hasNewDamages = "HasNewDamages"
        case plannedTime = "PlannedTime"
        case clientTime = "ClientTime"
        case actState = "ActState"
        case userId = "UserId"
        case userName = "UserName"
        case filialId = "FilialId"
        case filialName = "FilialName"
        case actSignState = "ActSignState"
        case images = "Images"
        case bodySchemeCode = "BodySchemeCode"
        case damageTypes = "DamageTypes"
        case repairTypes = "RepairTypes"
        case damages = "Damages"
    }
}

struct ActImage: Decodable {
    let id: Int?
    let url: String?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case url = "Url"
    }
}
