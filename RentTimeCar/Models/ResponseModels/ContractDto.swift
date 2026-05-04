//
//  ContractDto.swift
//  RentTimeCar
//

import Foundation

enum DogovorState: Int, Decodable {
    case additionalDogovor = -5
    case archivedDogovor = -4
    case reserved = -3
    case unknown1 = -2
    case unknown2 = -1
    case none = 0
    case requestStep1 = 1
    case requestStep2 = 2
    case requestStep3 = 3
    case requestStep4 = 4
    case requestStep5 = 5
    case temporarySave = 6
    case readyToSign = 7
    case opened = 8
    case closed = 9
    case realisation = 10
    case extended = 11
    case sold = 13
    case extendedClosed = 17
    case extendedOpened = 18
    case komissionCanceled = 19
    case komissionClose = 20
    case terminated = 30
    case defolt = 50
    case unknown = -999

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(Int.self)
        self = DogovorState(rawValue: value) ?? .unknown
    }
}

struct ContractsResponse: Decodable {
    let contracts: [ContractDto]

    enum CodingKeys: String, CodingKey {
        case contracts = "Contracts"
    }
}

struct ContractAddressDto: Decodable {
    let displayAddress: String?
    let lat: String?
    let lon: String?

    enum CodingKeys: String, CodingKey {
        case displayAddress = "DisplayAddress"
        case lat = "Lat"
        case lon = "Lon"
    }
}

struct ContractDto: Decodable {
    let id: Int
    let dateFrom: Date
    let dateTo: Date
    let vehicle: String?
    let vehicleId: Int64
    let allowedLocation: String?
    let deliveryAddress: ContractAddressDto?
    let returnAddress: ContractAddressDto?
    let contractNumber: String?
    let contractState: DogovorState
    let customContractState: Int
    let contractType: Int
    let totalBalanceSum: Decimal
    let finesGBDDBalance: Decimal
    let depositBalance: Decimal
    let rentBalance: Decimal
    let addServicesBalance: Decimal
    let otherBalance: Decimal

    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case dateFrom = "DateFrom"
        case dateTo = "DateTo"
        case vehicle = "Vehicle"
        case vehicleId = "VehicleId"
        case allowedLocation = "AllowedLocation"
        case deliveryAddress = "DeliveryAddress"
        case returnAddress = "ReturnAddress"
        case contractNumber = "ContractNumber"
        case contractState = "ContractState"
        case customContractState = "CustomContractState"
        case contractType = "ContractType"
        case totalBalanceSum = "TotalBalanceSum"
        case finesGBDDBalance = "FinesGBDDBalance"
        case depositBalance = "DepositBalance"
        case rentBalance = "RentBalance"
        case addServicesBalance = "AddServicesBalance"
        case otherBalance = "OtherBalance"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        vehicle = try container.decodeIfPresent(String.self, forKey: .vehicle)
        vehicleId = try container.decode(Int64.self, forKey: .vehicleId)
        allowedLocation = try container.decodeIfPresent(String.self, forKey: .allowedLocation)
        deliveryAddress = try container.decodeIfPresent(ContractAddressDto.self, forKey: .deliveryAddress)
        returnAddress = try container.decodeIfPresent(ContractAddressDto.self, forKey: .returnAddress)
        contractNumber = try container.decodeIfPresent(String.self, forKey: .contractNumber)
        contractState = try container.decode(DogovorState.self, forKey: .contractState)
        customContractState = try container.decode(Int.self, forKey: .customContractState)
        contractType = try container.decode(Int.self, forKey: .contractType)
        totalBalanceSum = (try? container.decode(Decimal.self, forKey: .totalBalanceSum)) ?? 0
        finesGBDDBalance = (try? container.decode(Decimal.self, forKey: .finesGBDDBalance)) ?? 0
        depositBalance = (try? container.decode(Decimal.self, forKey: .depositBalance)) ?? 0
        rentBalance = (try? container.decode(Decimal.self, forKey: .rentBalance)) ?? 0
        addServicesBalance = (try? container.decode(Decimal.self, forKey: .addServicesBalance)) ?? 0
        otherBalance = (try? container.decode(Decimal.self, forKey: .otherBalance)) ?? 0

        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        formatter.locale = Locale(identifier: "ru_RU")

        let dateFromStr = try container.decode(String.self, forKey: .dateFrom)
        let dateToStr = try container.decode(String.self, forKey: .dateTo)
        dateFrom = formatter.date(from: dateFromStr) ?? Date()
        dateTo = formatter.date(from: dateToStr) ?? Date()
    }

    // MARK: - Computed

    var carTitle: String? {
        vehicle?.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespaces)
    }

    var isCompleted: Bool {
        switch contractState {
        case .closed, .extendedClosed, .sold, .archivedDogovor, .terminated, .defolt, .komissionCanceled, .komissionClose:
            return true
        default:
            return false
        }
    }

    var statusTitle: String {
        switch contractState {
        case .opened, .extended, .extendedOpened, .realisation:
            return "Активна"
        case .readyToSign:
            return "К подписи"
        case .reserved:
            return "Бронь"
        case .closed, .extendedClosed, .komissionClose:
            return "Закрыт"
        case .terminated, .defolt, .komissionCanceled:
            return "Расторгнут"
        case .temporarySave:
            return "Черновик"
        case .requestStep1, .requestStep2, .requestStep3, .requestStep4, .requestStep5:
            return "Заявка"
        case .additionalDogovor:
            return "Доп. договор"
        default:
            return "Аренда"
        }
    }
}
