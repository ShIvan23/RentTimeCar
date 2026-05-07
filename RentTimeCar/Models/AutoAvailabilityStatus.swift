//
//  AutoAvailabilityStatus.swift
//  RentTimeCar
//

import UIKit

enum AutoAvailabilityStatus {
    case free
    case freeFrom(Date)
    case longTermRent

    var badgeText: String {
        switch self {
        case .free:
            return "Свободна"
        case .freeFrom(let date):
            let fmt = DateFormatter()
            fmt.dateFormat = "dd.MM"
            fmt.locale = Locale(identifier: "ru_RU")
            return "Свободна с \(fmt.string(from: date))"
        case .longTermRent:
            return "В долгосрочной аренде"
        }
    }

    var dotColor: UIColor {
        switch self {
        case .free:
            return .systemGreen
        case .freeFrom:
            return .systemYellow
        case .longTermRent:
            return .systemRed
        }
    }

    /// Вычисляет статус на основе занятых интервалов.
    /// - Parameters:
    ///   - intervals: список занятых периодов
    ///   - now: текущий момент
    ///   - monthLater: граница «долгосрочной аренды» (now + 1 месяц)
    static func compute(from intervals: [UsedInterval], now: Date, monthLater: Date) -> AutoAvailabilityStatus {
        let sorted = intervals.sorted { $0.timeBegin < $1.timeBegin }

        // Машина сейчас занята?
        let isBusy = sorted.contains { $0.timeBegin <= now && $0.timeEnd >= now }
        guard isBusy else { return .free }

        // Идём по цепочке интервалов от now и находим конец непрерывной занятости
        var chainEnd = now
        for interval in sorted {
            guard interval.timeBegin <= chainEnd else { break }
            if interval.timeEnd > chainEnd {
                chainEnd = interval.timeEnd
            }
        }

        return chainEnd >= monthLater ? .longTermRent : .freeFrom(chainEnd)
    }
}
