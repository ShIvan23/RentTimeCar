//
//  FilterVCType.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 14.08.2025.
//

import UIKit

enum FilterVCType {
    case date([Date])
    case brandAuto(FilterBrandAuto)
    case price(FilterValueModel)
    case motorPower(FilterValueModel)
    case classAuto(FilterClassAuto)
    case separator
    case title(String)
}

struct FilterBrandAuto {
    let name: String
    let image: UIImage?
    var isSelected = false
}

struct FilterValueModel {
    let minValue: Int
    let maxValue: Int
    var minValueNow: Int
    var maxValueNow: Int
    
    init(minValue: Int, maxValue: Int) {
        self.minValue = minValue
        self.maxValue = maxValue
        minValueNow = minValue
        maxValueNow = maxValue
    }
}

struct FilterClassAuto {
    let name: String
    var isSelected = false
}

extension FilterVCType {
    static func makeDefaultModel() -> [FilterVCType] {
        let brands: [FilterVCType] = FilterService.shared.brands.map {
            .brandAuto($0)
        }
        let classesAuto: [FilterVCType] = FilterService.shared.classesAuto.map {
            .classAuto($0)
        }
        var result: [FilterVCType] = [
            .date([]),
            .separator,
            .title("Марка")
        ]
        result.append(contentsOf: brands)
        result.append(.separator)
        result.append(.title("Цена за сутки ₽"))
        let minPrice = FilterService.shared.price.min
        let maxPrice = FilterService.shared.price.max
        result.append(.price(FilterValueModel(minValue: minPrice, maxValue: maxPrice)))
        result.append(.separator)
        result.append(.title("Мощность л.с."))
        let minMotorPower = FilterService.shared.motorPower.min
        let maxMotorPower = FilterService.shared.motorPower.max
        result.append(.motorPower(FilterValueModel(minValue: minMotorPower, maxValue: maxMotorPower)))
        result.append(.separator)
        result.append(.title("Класс"))
        result.append(contentsOf: classesAuto)
        result.append(.separator)
        return result
    }
}
