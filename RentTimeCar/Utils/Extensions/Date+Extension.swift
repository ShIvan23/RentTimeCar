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
}
