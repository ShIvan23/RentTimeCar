//
//  UsedInterval.swift
//  RentTimeCar
//

import Foundation

struct UsedInterval: Decodable {
    let autoState: Int
    let timeBegin: Date
    let timeEnd: Date
    let contractId: Int
    let contractState: Int
    let contractCustomState: Int
    let contractType: Int
    let contractFilialFromId: Int
    let contractFilialToId: Int

    enum CodingKeys: String, CodingKey {
        case autoState = "AutoState"
        case timeBegin = "TimeBegin"
        case timeEnd = "TimeEnd"
        case contractId = "ContractId"
        case contractState = "ContractState"
        case contractCustomState = "ContractCustomState"
        case contractType = "ContractType"
        case contractFilialFromId = "ContractFilialFromId"
        case contractFilialToId = "ContractFilialToId"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        autoState = try container.decode(Int.self, forKey: .autoState)
        contractId = try container.decode(Int.self, forKey: .contractId)
        contractState = try container.decode(Int.self, forKey: .contractState)
        contractCustomState = try container.decode(Int.self, forKey: .contractCustomState)
        contractType = try container.decode(Int.self, forKey: .contractType)
        contractFilialFromId = try container.decode(Int.self, forKey: .contractFilialFromId)
        contractFilialToId = try container.decode(Int.self, forKey: .contractFilialToId)

        let fmt = DateFormatter()
        fmt.dateFormat = "dd.MM.yyyy HH:mm:ss"
        fmt.locale = Locale(identifier: "ru_RU")

        let beginStr = try container.decode(String.self, forKey: .timeBegin)
        let endStr = try container.decode(String.self, forKey: .timeEnd)
        timeBegin = fmt.date(from: beginStr) ?? Date.distantPast
        timeEnd = fmt.date(from: endStr) ?? Date.distantPast
    }
}
