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

struct Tarif: Decodable {
    let id: Int

    enum CodingKeys: String, CodingKey {
        case id = "Id"
    }
}

struct PrimaryInfo: Decodable {
    let passengerCount: Int

    enum CodingKeys: String, CodingKey {
        case passengerCount = "PassengerCount"
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
    let itemID: Int
    let tarifs: [Tarif]
    let modInfoV3: String
    let modInfoPrivod: String
    let primaryInfo: PrimaryInfo

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
        case itemId = "ItemID"
        case tarifs = "Tarifs"
        case modInfoV3 = "ModInfoV3"
        case modInfoPrivod = "ModInfoPrivod"
        case primaryInfo = "PrimaryInfo"
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
        additionalServices: [AdditionalService],
        itemID: Int,
        tarifs: [Tarif],
        modInfoV3: String,
        modInfoPrivod: String,
        primaryInfo: PrimaryInfo
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
        self.itemID = itemID
        self.tarifs = tarifs
        self.modInfoV3 = modInfoV3
        self.modInfoPrivod = modInfoPrivod
        self.primaryInfo = primaryInfo
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
        let allServices = (try? container.decode([AdditionalService].self, forKey: .additionalServices)) ?? []
        self.additionalServices = allServices.filter { !$0.serviceTitle.isExcludedService }
        self.itemID = try container.decode(Int.self, forKey: .itemId)
        self.tarifs = (try? container.decode([Tarif].self, forKey: .tarifs)) ?? []
        self.modInfoV3 = try container.decode(String.self, forKey: .modInfoV3)
        self.modInfoPrivod = try container.decode(String.self, forKey: .modInfoPrivod)
        self.primaryInfo = try container.decode(PrimaryInfo.self, forKey: .primaryInfo)
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
