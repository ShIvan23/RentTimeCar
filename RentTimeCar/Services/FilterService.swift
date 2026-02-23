//
//  BrandAutoService.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 14.08.2025.
//

import Foundation

final class FilterService {
    static let shared = FilterService()

    // MARK: - Internal Properties

    private(set) var allAutos: [Auto] = []
    private(set) var brands = [FilterBrandAuto]()
    private(set) var price: (min: Int, max: Int) = (.zero, .zero)
    private(set) var motorPower: (min: Int, max: Int) = (.zero, .zero)
    private(set) var classesAuto = [FilterInfoAuto]()
    private(set) var sortingAuto: [FilterInfoAuto]

    private(set) var selectedDates = [Date]()
    private(set) var selectedPrice: (min: Int, max: Int) = (.zero, .zero)
    private(set) var selectedMotorPower: (min: Int, max: Int) = (.zero, .zero)
    private(set) var filteredAutos: [Auto] = []
    private(set) var selectedBrands: [String] = []

    // MARK: - Private Properties

    private let rentApiFacade: IRentApiFacade = RentApiFacade()
    private var autoClassesCodes = [String: String]()

    private init () {
        sortingAuto = [
            FilterInfoAuto(name: "По классу"),
            FilterInfoAuto(name: "По марке"),
            FilterInfoAuto(name: "По цене (по возрастанию)"),
        ]
        fetchAutoClassesCodes()
    }
    
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

    func setSelectedMotorPower(min: Int, max: Int) {
        selectedMotorPower.min = min
        selectedMotorPower.max = max
    }

    func updateFilterInfo(for type: BottomSheetType, item: FilterInfoAuto) {
        switch type {
        case .sorting:
            guard let index = sortingAuto.firstIndex(where: { $0.name == item.name }) else { return }
            sortingAuto[index] = item
            NotificationCenter.default.post(name: .sortingAutoUpdated, object: nil)
        case .autoType:
            guard let index = classesAuto.firstIndex(where: { $0.name == item.name }) else { return }
            classesAuto[index] = item
            NotificationCenter.default.post(name: .classAutoUpdated, object: nil)
        }
    }

    func resetAllFilters() {
        selectedDates = []
        selectedPrice.min = price.min
        selectedPrice.max = price.max
        filteredAutos = []
        selectedBrands = []
        NotificationCenter.default.post(name: .filteredAutosUpdated, object: nil)
    }

    func getSelectedAutosClassesCodes() -> [String] {
        let selectedAutoClasses = classesAuto.compactMap { $0.isSelected ? $0.name : nil }
        var codes = [String]()
        selectedAutoClasses.forEach {
            guard let value = autoClassesCodes[$0] else { return }
            codes.append(value)
        }
        return codes
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
                FilterInfoAuto(name: $0)
            }
        }
    }

    private func fetchAutoClassesCodes() {
        rentApiFacade.getFilterPrams { [weak self] result in
            switch result {
            case .success(let model):
                self?.makeAutoClassesCodes(with: model.result)
            case .failure(let failure):
                print("+++ failure = \(failure)")
                break
            }
        }
    }

    private func makeAutoClassesCodes(with model: GetFilterParams?) {
        guard let model else { return }
        model.autoClassCodes.forEach {
            autoClassesCodes[$0.title] = $0.code
        }
    }
}

extension Notification.Name {
    static let selectedDatesUpdated = Notification.Name("selectedDatesUpdated")
    static let filteredAutosUpdated = Notification.Name("filteredAutosUpdated")
    static let sortingAutoUpdated = Notification.Name("sortingAutoUpdated")
    static let classAutoUpdated = Notification.Name("classAutoUpdated")
}
