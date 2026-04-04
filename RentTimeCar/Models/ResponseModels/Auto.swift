//
//  Autos.swift
//  RentTimeCar
//
//  Created by Ekaterina Volobueva on 01.08.2025.
//

import Foundation

struct AdditionalService: Decodable {
    let serviceTitle: String
    let basePrice: Int
    let currentBasePrice: Int

    var effectivePrice: Int {
        basePrice == 0 ? currentBasePrice : basePrice
    }

    init(serviceTitle: String, basePrice: Int = 0, currentBasePrice: Int = 0) {
        self.serviceTitle = serviceTitle
        self.basePrice = basePrice
        self.currentBasePrice = currentBasePrice
    }

    enum CodingKeys: String, CodingKey {
        case serviceTitle = "ServiceTitle"
        case basePrice = "BasePrice"
        case currentBasePrice = "CurrentBasePrice"
    }
}

struct Auto: Decodable {
    let title: String
    let files: [File]
    let defaultPriceWithDiscountSt: Int
    let deposit: Int
    let marka: String
    let motorPower: Int
    let classAuto: String
    let mileageLimit: Int
    let fuelType: String
    let additionalServices: [AdditionalService]

    enum CodingKeys: String, CodingKey {
        case files = "Files"
        case title = "Title"
        case defaultPriceWithDiscountSt = "DefaultPriceWithDiscountSt"
        case deposit = "Deposit"
        case marka = "Marka"
        case motorPower = "ModInfoPowerLSValue"
        case classAuto = "AutoClassTitle"
        case mileageLimit = "MileageLimit"
        case fuelType = "FuelType"
        case additionalServices = "AdditionalServices"
    }

    init(
        title: String,
        files: [File],
        defaultPriceWithDiscountSt: Int,
        deposit: Int,
        marka: String,
        motorPower: Int,
        classAuto: String,
        mileageLimit: Int,
        fuelType: String,
        additionalServices: [AdditionalService]
    ) {
        self.title = title
        self.files = files
        self.defaultPriceWithDiscountSt = defaultPriceWithDiscountSt
        self.deposit = deposit
        self.marka = marka
        self.motorPower = motorPower
        self.classAuto = classAuto
        self.mileageLimit = mileageLimit
        self.fuelType = fuelType
        self.additionalServices = additionalServices
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.files = try container.decode([File].self, forKey: .files)
        self.title = try container.decode(String.self, forKey: .title)
        // DefaultPriceWithDiscountSt приходит как Double (8500.0)
        self.defaultPriceWithDiscountSt = Int(try container.decode(Double.self, forKey: .defaultPriceWithDiscountSt))
        self.deposit = try container.decode(Int.self, forKey: .deposit)
        self.marka = try container.decode(String.self, forKey: .marka)
        self.motorPower = try container.decode(Int.self, forKey: .motorPower)
        self.classAuto = try container.decode(String.self, forKey: .classAuto)
        self.mileageLimit = try container.decode(Int.self, forKey: .mileageLimit)
        self.fuelType = try container.decode(String.self, forKey: .fuelType)
        let allServices = try container.decode([AdditionalService].self, forKey: .additionalServices)
        self.additionalServices = allServices.filter { !$0.serviceTitle.isExcludedService }
    }
}

struct File: Decodable {
    let url: String?
    let folder: String

    private enum CodingKeys: String, CodingKey {
        case url = "url"
        case folder
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let folder = try container.decode(String.self, forKey: .folder)
        let url = try container.decodeIfPresent(String.self, forKey: .url)
        if folder == .folderImageValue {
            self.url = url
            self.folder = folder
        } else if folder == .folderBrandValue {
            self.url = url
            self.folder = folder
        } else {
            self.url = nil
            self.folder = folder
        }
    }
}

extension String {
    static let folderImageValue = "brandImage"
    static let folderBrandValue = "folder"

    fileprivate var isExcludedService: Bool {
        let excluded: [String] = ["перепробег", "топливо", "повреждения тс", "увеличение скорости", "киловатты"]
        let lowercased = self.lowercased()
        return excluded.contains { lowercased.contains($0) }
    }
}
