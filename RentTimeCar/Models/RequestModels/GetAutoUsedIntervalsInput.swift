//
//  GetAutoUsedIntervalsInput.swift
//  RentTimeCar
//

import Foundation

struct GetAutoUsedIntervalsInput: Encodable {
    let objectId: String
    let dateFrom: String
    let dateTo: String
}
