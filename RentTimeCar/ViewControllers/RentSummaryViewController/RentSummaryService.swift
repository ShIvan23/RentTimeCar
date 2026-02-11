//
//  RentSummaryService.swift
//  RentTimeCar
//
//  Created by Андрей Пермяков on 10.02.2026.
//

import UIKit

final class RentSummaryService {
    static let shared = RentSummaryService()
    
    private init() {}
    
    func getRentSummaryItems(selectedOptions: [String]) -> [RentItem] {
        //найти откуда приходит стоимость аренды
        let baseRent = 45000
        var items: [RentItem] = []
        //базовая аренда с иконкой, найти где взять цену
        items.append(RentItem(title: "Аренда", amount: baseRent, icon: .calendar))
        // так как нет цен при выборе опций, сделан массив и при совпадении добавляем виртуальную цену
        let extrasPrice: [String:Int] = [
            "100% Защита": 15000,
            "Доп. водитель": 10000,
            "Детское кресло": 0
        ]
        // если есть выбранные дополнительные опции, добавляем заголовок
        if !selectedOptions.isEmpty {
            items.append(RentItem(title: "Дополнительные опции:", amount: 0, icon: .file))
            // Добавляем каждую выбранную опцию с её ценой
            for option in selectedOptions {
                if let price = extrasPrice[option] {
                    items.append(RentItem(title: " •  \(option)", amount: price, icon: nil))
                }
            }
        }
        //посчитали сумму выбранных опций
        let extrasTotal = items.filter { $0.amount > 0 && $0.title != "Аренда" }.map(\.amount).reduce(0, +)
        //итоговая сумма
        let total = baseRent + extrasTotal
        let deposite = total / 2  //задать логику депозита
        items.append(RentItem(title: "Итого", amount: total, icon: .rublesign))
        items.append(RentItem(title: "Депозит", amount: deposite, icon: .rublesignBank))
        
        return items
    }
}
