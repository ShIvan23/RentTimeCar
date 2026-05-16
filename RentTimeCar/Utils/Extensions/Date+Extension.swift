//
//  Date+Extension.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 14.10.2025.
//

import Foundation

extension Date {
    // Returns date formatted as "dd.MM.yyyy HH:mm:ss" in the device's local timezone,
    // as required by /api/contracts/create.
    func toContractDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        formatter.timeZone = .current
        return formatter.string(from: self)
    }

    func convertDateToString() -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = .current
        let dateString = dateFormatter.string(from: self)
        return dateString
    }

    static func convertArrayDatesToString(_ dates: [Date]) -> String? {
        guard let firstDate = dates.first,
              let lastDate = dates.last else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        let firstDateString = dateFormatter.string(from: firstDate)
        let lastDateString = dateFormatter.string(from: lastDate)
        return "C \(firstDateString) по \(lastDateString)"
    }
}
