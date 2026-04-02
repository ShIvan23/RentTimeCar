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
    private(set) var autoClassesCodes = [String: FilterInfoAuto]()
    private(set) var sortingAuto: [FilterInfoAuto]

    private(set) var selectedDates = [Date]()
    private(set) var selectedPrice: (min: Int, max: Int) = (.zero, .zero)
    private(set) var selectedMotorPower: (min: Int, max: Int) = (.zero, .zero)
    private(set) var filteredAutos: [Auto] = []
    private(set) var selectedBrands: [String] = []

    // MARK: - Private Properties

    private let rentApiFacade: IRentApiFacade = RentApiFacade()
    private var rentApiFacadeRetriesCount = 5

    private init () {
        sortingAuto = [
            FilterInfoAuto(name: .filterClassText),
            FilterInfoAuto(name: .filterBrandText),
            FilterInfoAuto(name: .filterPriceText),
        ]
        fetchAutoClassesCodes()
    }
    
    var hasFilters: Bool {
        !selectedDates.isEmpty
            || selectedPrice.min != price.min
            || selectedPrice.max != price.max
            || !selectedBrands.isEmpty
            || autoClassesCodes.values.contains(where: { $0.isSelected })
    }
    
    func setModel(_ model: [Auto]) {
        allAutos = model
        makeBrands(with: model)
        makePrices(with: model)
        makeMotorPower(with: model)
    }
    
    func setSelectedDates(_ selectedDates: [Date]) {
        self.selectedDates = selectedDates
        NotificationCenter.default.post(name: .selectedDatesUpdated, object: nil)
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
            
        case .autoType:
            
            var keyForChange: String?
            autoClassesCodes.forEach { key, value in
                if value.name == item.name {
                    keyForChange = key
                }
            }
            guard let keyForChange else { return }
            autoClassesCodes[keyForChange] = item
            
        }
        searchAutos { autos in
            self.setFilteredAutos(autos)
            switch type {
            case .sorting:
                NotificationCenter.default.post(name: .sortingAutoUpdated, object: nil)
            case .autoType:
                NotificationCenter.default.post(name: .classAutoUpdated, object: nil)
            }
        }
    }

    func resetAllFilters() {
        selectedDates = []
        selectedPrice.min = price.min
        selectedPrice.max = price.max
        filteredAutos = []
        selectedBrands = []
        var newAutoClasses = [String: FilterInfoAuto]()
        autoClassesCodes.forEach {
            newAutoClasses[$0] = FilterInfoAuto(name: $1.name, isSelected: false)
        }
        autoClassesCodes = newAutoClasses
        sortingAuto = sortingAuto.map { FilterInfoAuto(name: $0.name, isSelected: false) }
        NotificationCenter.default.post(name: .filteredAutosUpdated, object: nil)
    }

    func searchAutos(completion: @escaping ([Auto]) -> Void) {
        let selectedAutoClasses = getSelectedAutosClassesCodes()
        let input = SearchAutoInput(
            dateFrom: selectedDates.first?.convertDateToString() ?? .defaultDate,
            dateTo: selectedDates.last?.convertDateToString() ?? .defaultDate,
            brands: selectedBrands,
            defaultPriceFrom: selectedPrice.min,
            defaultPriceTo: selectedPrice.max,
            autoClasses: selectedAutoClasses,
            powerMin: selectedMotorPower.min,
            powerMax: selectedMotorPower.max
        )
        rentApiFacade.searchAuto(with: input) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case let .success(model):
                    self.setFilteredAutos(model.result ?? [])
                    NotificationCenter.default.post(name: .filteredAutosUpdated, object: nil)
                    completion(model.result ?? [])
                    self.rentApiFacadeRetriesCount = 5
                case .failure:
                    guard self.rentApiFacadeRetriesCount != .zero else { return }
                    self.rentApiFacadeRetriesCount -= 1
                    self.searchAutos(completion: completion)
                }
            }
        }
    }

    private func getSelectedAutosClassesCodes() -> [String] {
        let selectedAutoClasses = autoClassesCodes.compactMap { $1.isSelected ? $0 : nil }
        return selectedAutoClasses
    }
    
    private func setFilteredAutos(_ autos: [Auto]) {
        filteredAutos = sortIfNeeded(autos)
    }
    
    private func sortIfNeeded(_ autos: [Auto]) -> [Auto] {
        guard let hasSotingItem = sortingAuto.first(where: { $0.isSelected }) else { return autos }
        switch hasSotingItem.name {
        case .filterClassText:
            return autos.sorted(by: { $0.classAuto > $1.classAuto })
        case .filterBrandText:
            return autos.sorted(by: { $0.marka < $1.marka })
        case .filterPriceText:
            return autos.sorted(by: { $0.defaultPriceWithDiscountSt < $1.defaultPriceWithDiscountSt })
        default:
            return autos
        }
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

    private func fetchAutoClassesCodes() {
        rentApiFacade.getFilterPrams { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let model):
                makeAutoClassesCodes(with: model.result)
                rentApiFacadeRetriesCount = 5
            case .failure:
                guard rentApiFacadeRetriesCount != .zero else { return }
                rentApiFacadeRetriesCount -= 1
                fetchAutoClassesCodes()
            }
        }
    }

    private func makeAutoClassesCodes(with model: GetFilterParams?) {
        guard let model else { return }
        model.autoClassCodes.forEach {
            autoClassesCodes[$0.code] = FilterInfoAuto(name: $0.title)
        }
    }
}

private extension String {
    static let defaultDate = "1900.01.01 00:00:00"
    static let filterClassText = "По классу"
    static let filterBrandText = "По марке"
    static let filterPriceText = "По цене (по возрастанию)"
}

extension Notification.Name {
    static let selectedDatesUpdated = Notification.Name("selectedDatesUpdated")
    static let filteredAutosUpdated = Notification.Name("filteredAutosUpdated")
    static let sortingAutoUpdated = Notification.Name("sortingAutoUpdated")
    static let classAutoUpdated = Notification.Name("classAutoUpdated")
}
