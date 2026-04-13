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
    case classAuto(FilterInfoAuto)
    case separator
    case title(String)
}

struct FilterBrandAuto {
    let name: String
    let image: String?
    var isSelected = false
}

struct FilterValueModel {
    let minValue: Int
    let maxValue: Int
    var minValueNow: Int
    var maxValueNow: Int
    
    init(minValue: Int, maxValue: Int, minValueNow: Int, maxValueNow: Int) {
        self.minValue = minValue
        self.maxValue = maxValue
        self.minValueNow = minValueNow
        self.maxValueNow = maxValueNow
    }
}

struct FilterInfoAuto {
    let name: String
    var isSelected = false

    init(name: String, isSelected: Bool = false) {
        self.name = name
        self.isSelected = isSelected
    }
}

extension FilterVCType {
    static func makeDefaultModel() -> [FilterVCType] {
        let brands: [FilterVCType] = FilterService.shared.brands.map {
            .brandAuto(
                FilterBrandAuto(
                    name: $0.name,
                    image: $0.image,
                    isSelected: FilterService.shared.selectedBrands.contains($0.name)
                )
            )
        }
        let classesAuto: [FilterVCType] = FilterService.shared.autoClassesCodes.values.map {
            .classAuto($0)
        }
        var result: [FilterVCType] = [
            .date(FilterService.shared.selectedDates),
            .separator,
            .title("Марка")
        ]
        result.append(contentsOf: brands)
        result.append(.separator)
        result.append(.title("Цена за сутки ₽"))
        let minPrice = FilterService.shared.price.min
        let maxPrice = FilterService.shared.price.max
        let minPriceNow = FilterService.shared.selectedPrice.min
        let maxPriceNow = FilterService.shared.selectedPrice.max
        result.append(
            .price(
                FilterValueModel(
                    minValue: minPrice,
                    maxValue: maxPrice,
                    minValueNow: minPriceNow,
                    maxValueNow: maxPriceNow
                )
            )
        )
        result.append(.separator)
        result.append(.title("Мощность л.с."))
        let minMotorPower = FilterService.shared.motorPower.min
        let maxMotorPower = FilterService.shared.motorPower.max
        let minMotorPowerNow = FilterService.shared.selectedMotorPower.min
        let maxMotorPowerNow = FilterService.shared.selectedMotorPower.max
        result
            .append(
                .motorPower(
                    FilterValueModel(
                        minValue: minMotorPower,
                        maxValue: maxMotorPower,
                        minValueNow: minMotorPowerNow,
                        maxValueNow: maxMotorPowerNow
                    )
                )
            )
        result.append(.separator)
        result.append(.title("Класс"))
        result.append(contentsOf: classesAuto)
        result.append(.separator)
        return result
    }
}
