//
//  RentSummaryService.swift
//  RentTimeCar
//
//  Created by Андрей Пермяков on 10.02.2026.
//

import UIKit

final class RentSummaryService {
    
    // MARK: - Public Properties
    static let shared = RentSummaryService()
    
    // MARK: - Init
    private init() {}
    
    // MARK: - Public Methods
    func getRentSummaryItems(selectedOptions: [String]) -> [RentItem] {
        let baseRent = 45000
        var items: [RentItem] = []
        items.append(RentItem(title: "Аренда", amount: baseRent, icon: .calendar))
        let extrasPrice: [String:Int] = [
            "100% Защита": 15000,
            "Доп. водитель": 10000,
            "Детское кресло": 0
        ]
        if !selectedOptions.isEmpty {
            items.append(RentItem(title: "Дополнительные опции:", amount: 0, icon: .file))
            for option in selectedOptions {
                if let price = extrasPrice[option] {
                    items.append(RentItem(title: " •  \(option)", amount: price, icon: nil))
                }
            }
        }
        let extrasTotal = items.filter { $0.amount > 0 && $0.title != "Аренда" }.map(\.amount).reduce(0, +)
        let total = baseRent + extrasTotal
        let deposite = total / 2  //задать логику депозита
        items.append(RentItem(title: "Итого", amount: total, icon: .rublesign))
        items.append(RentItem(title: "Депозит", amount: deposite, icon: .rublesignBank))
        
        return items
    }
}
