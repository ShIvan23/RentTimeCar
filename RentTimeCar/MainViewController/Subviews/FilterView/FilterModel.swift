//
//  FilterModel.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 13.08.2025.
//

import UIKit

struct FilterModel {
    let type: FilterType
    let image: UIImage
    let text: String?
    var selectedTextFilter: String?
}

enum FilterType {
    case filter
    case date
    case sort
    case autoType
    case delete
}

extension FilterModel {
    static func makeFilterModel() -> [FilterModel] {
        return [
            FilterModel(
                type: .filter,
                image: .filter,
                text: "Фильтр"
            ),
            FilterModel(
                type: .date,
                image: .calendar,
                text: "Даты"
            ),
            FilterModel(
                type: .sort,
                image: .sorting,
                text: "Сортировка"
            ),
            FilterModel(
                type: .autoType,
                image: .car2,
                text: "Тип авто"
            ),
        ]
    }
    
    static func removeFilter() -> FilterModel {
        FilterModel(
            type: .delete,
            image: .bin,
            text: nil
        )
    }
}
