//
//  ActInfoResponse.swift
//  RentTimeCar
//

import Foundation

enum ActState: Int, Decodable {
    case none = 0
    case selected = 1
    case inProgress = 2
    case finished = 3
    case canceled = 4
    case aborted = 5
    case draft = 6

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(Int.self)
        self = ActState(rawValue: value) ?? .none
    }

    var title: String {
        switch self {
        case .none: return "Ожидает заполнения"
        case .selected: return "Взят в работу"
        case .inProgress: return "В работе"
        case .finished: return "Завершён"
        case .canceled: return "Отменён"
        case .aborted: return "Отказ клиента"
        case .draft: return "Черновик"
        }
    }
}

enum AutoCleanStatus: Int, Decodable {
    case unknown = -1
    case clean = 0
    case dirty = 1

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(Int.self)
        self = AutoCleanStatus(rawValue: value) ?? .unknown
    }

    var title: String {
        switch self {
        case .clean: return "Чистый"
        case .dirty: return "Грязный"
        case .unknown: return "—"
        }
    }
}

struct ActInfoResponse: Decodable {
    let id: Int
    let actType: Int
    let mileage: Int
    let fuelCount: Int
    let bodyStatus: AutoCleanStatus
    let salonStatus: AutoCleanStatus
    let truncStatus: AutoCleanStatus
    let hasNewDamages: Bool
    let plannedTime: String
    let clientTime: String
    let actState: ActState
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
