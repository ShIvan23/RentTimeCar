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
    
    private(set) var allAutos: [Auto] = []
    private(set) var brands = [FilterBrandAuto]()
    private(set) var price: (min: Int, max: Int) = (.zero, .zero)
    private(set) var motorPower: (min: Int, max: Int) = (.zero, .zero)
    private(set) var classesAuto = [FilterClassAuto]()

    private(set) var selectedDates = [Date]()
    private(set) var selectedPrice: (min: Int, max: Int) = (.zero, .zero)
    private(set) var filteredAutos: [Auto] = []
    private(set) var selectedBrands: [String] = []
    // нужна проперти на фильтр по мощности
    
    var hasFilters: Bool {
        !selectedDates.isEmpty || selectedPrice.min != price.min || selectedPrice.max != price.max || !filteredAutos.isEmpty
    }
    
    func setModel(_ model: [Auto]) {
        allAutos = model
        makeBrands(with: model)
        makePrices(with: model)
        makeMotorPower(with: model)
        makeClassesAuto(with: model)
    }
    
    func setSelectedDates(_ selectedDates: [Date]) {
        self.selectedDates = selectedDates
        NotificationCenter.default.post(name: .selectedDatesUpdated, object: nil)
    }
    
    func setFilteredAutos(_ autos: [Auto]) {
        filteredAutos = autos
    }
    
    func setSelectedBrands(_ brands: [String]) {
        selectedBrands = brands
    }
    
    func setSelectedPrice(min: Int, max: Int) {
        selectedPrice.min = min
        selectedPrice.max = max
    }
    
    func resetAllFilters() {
        selectedDates = []
        selectedPrice.min = price.min
        selectedPrice.max = price.max
        filteredAutos = []
        selectedBrands = []
        NotificationCenter.default.post(name: .filteredAutosUpdated, object: nil)
    }
    
    private func makeBrands(with model: [Auto]) {
        DispatchQueue.global(qos: .userInteractive).async {
            var brandsSet = Set<String>()
            model.enumerated().forEach { index, item in
                
                let image = item.files.first(where: { $0.folder == .folderBrandValue })?.url
                if index == .zero {
                    self.brands.append(FilterBrandAuto(name: item.marka, image: image))
                } else {
                    if !brandsSet.contains(item.marka.lowercased()) {
                        self.brands.append(FilterBrandAuto(name: item.marka, image: image))
                    }
                }
                brandsSet.insert(item.marka.lowercased())
            }
            self.brands = self.brands.sorted(by: { $0.name < $1.name })
        }
    }
    
    private func makePrices(with model: [Auto]) {
        DispatchQueue.global(qos: .userInteractive).async {
            let allPrices = model.map {
                $0.defaultPriceWithDiscountSt
            }
            self.price.min = allPrices.min() ?? .zero
            self.price.max = allPrices.max() ?? .zero
            self.selectedPrice.min = self.price.min
            self.selectedPrice.max = self.price.max
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

extension Notification.Name {
    static let selectedDatesUpdated = Notification.Name("selectedDatesUpdated")
    static let filteredAutosUpdated = Notification.Name("filteredAutosUpdated")
}
