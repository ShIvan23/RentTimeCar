//
//  Date+Extension.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 14.10.2025.
//

import Foundation

extension Date {
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
