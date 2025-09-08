//
//  BrandAutoService.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 14.08.2025.
//

import Foundation

final class FilterService {
    static let shared = FilterService()
    
    private init () {}
    
    private(set) var brands = [FilterBrandAuto]()
    private(set) var price: (min: Int, max: Int) = (.zero, .zero)
    private(set) var motorPower: (min: Int, max: Int) = (.zero, .zero)
    private(set) var classesAuto = [FilterClassAuto]()
    
    func setModel(_ model: [Auto]) {
        makeBrands(with: model)
        makePrices(with: model)
        makeMotorPower(with: model)
        makeClassesAuto(with: model)
    }
    
    private func makeBrands(with model: [Auto]) {
        DispatchQueue.global(qos: .userInteractive).async {
            var brandsSet = Set<String>()
            model.forEach {
                brandsSet.insert($0.marka)
            }
            self.brands = Array(brandsSet)
                .sorted(by: <)
                .map {
                    FilterBrandAuto(name: $0, image: nil)
                }
        }
    }
    
    private func makePrices(with model: [Auto]) {
        DispatchQueue.global(qos: .userInteractive).async {
            let allPrices = model.map {
                $0.defaultPriceWithDiscountSt
            }
            self.price.min = allPrices.min() ?? .zero
            self.price.max = allPrices.max() ?? .zero
        }
    }
    
    private func makeMotorPower(with model: [Auto]) {
        DispatchQueue.global(qos: .userInteractive).async {
            let allMotorPowers = model.map {
                $0.motorPower
            }
            self.motorPower.min = allMotorPowers.min() ?? .zero
            self.motorPower.max = allMotorPowers.max() ?? .zero
        }
    }
    
    private func makeClassesAuto(with model: [Auto]) {
        DispatchQueue.global(qos: .userInteractive).async {
            var setOfClasses: Set<String> = []
            model.forEach {
                setOfClasses.insert($0.classAuto)
            }
            self.classesAuto = setOfClasses.map {
                FilterClassAuto(name: $0)
            }
        }
    }
}
