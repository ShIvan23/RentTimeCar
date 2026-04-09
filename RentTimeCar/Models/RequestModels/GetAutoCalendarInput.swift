//
//  GetAutoCalendarInput.swift
//  RentTimeCar
//

import Foundation

struct GetAutoCalendarInput: Encodable {
    let objectId: String
    let dateFrom: String
    let dateTo: String
}
