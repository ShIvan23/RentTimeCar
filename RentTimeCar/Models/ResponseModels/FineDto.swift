//
//  FineDto.swift
//  RentTimeCar
//

import Foundation

struct FineDto: Decodable {
    let id: Int64
    let creationDate: Date?
    let violationDate: Date?
    let vehicleGibddNumber: String?
    let documentType: FinesDocumentType
    let documentNumber: String?
    let sum: Decimal?
    let gibddStatus: PaidStatuses
    let vehicle: String?
    let contractNumber: String?
    let client: String?
    let calculationSum: Decimal?
    let toPaymentSum: Decimal?
    let calculationCode: String?
    let calculationStatus: PaymentInternalStatuses
    let companyPayment: Bool?
    let payToDueDate: Date
    let koapEntityId: String?
    let koapEntityDescription: String?
    let attachedImageUris: [String]?
    let uniqueFineId: String?
    let discountEffectTitle: String?
    let discountEffectCountDays: Int
    let location: String?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case creationDate = "CreationDate"
        case violationDate = "ViolationDate"
        case vehicleGibddNumber = "VehicleGibddNumber"
        case documentType = "DocumentType"
        case documentNumber = "DocumentNumber"
        case sum = "Sum"
        case gibddStatus = "GibddStatus"
        case vehicle = "Vehicle"
        case contractNumber = "ContractNumber"
        case client = "Client"
        case calculationSum = "CalculationSum"
        case toPaymentSum = "ToPaymentSum"
        case calculationCode = "CalculationCode"
        case calculationStatus = "CalculationStatus"
        case companyPayment = "CompanyPayment"
        case payToDueDate = "PayToDueDate"
        case koapEntityId = "KoapEntityId"
        case koapEntityDescription = "KoapEntityDescription"
        case attachedImageUris = "AttachedImageUris"
        case uniqueFineId = "UniqueFineId"
        case discountEffectTitle = "DiscountEffectTitle"
        case discountEffectCountDays = "DiscountEffectCountDays"
        case location = "Location"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int64.self, forKey: .id)
        vehicleGibddNumber = try container.decodeIfPresent(String.self, forKey: .vehicleGibddNumber)
        documentType = try container.decode(FinesDocumentType.self, forKey: .documentType)
        documentNumber = try container.decodeIfPresent(String.self, forKey: .documentNumber)
        sum = try container.decodeIfPresent(Decimal.self, forKey: .sum)
        gibddStatus = try container.decode(PaidStatuses.self, forKey: .gibddStatus)
        vehicle = try container.decodeIfPresent(String.self, forKey: .vehicle)
        contractNumber = try container.decodeIfPresent(String.self, forKey: .contractNumber)
        client = try container.decodeIfPresent(String.self, forKey: .client)
        calculationSum = try container.decodeIfPresent(Decimal.self, forKey: .calculationSum)
        toPaymentSum = try container.decodeIfPresent(Decimal.self, forKey: .toPaymentSum)
        calculationCode = try container.decodeIfPresent(String.self, forKey: .calculationCode)
        calculationStatus = try container.decode(PaymentInternalStatuses.self, forKey: .calculationStatus)
        companyPayment = try container.decodeIfPresent(Bool.self, forKey: .companyPayment)
        koapEntityId = try container.decodeIfPresent(String.self, forKey: .koapEntityId)
        koapEntityDescription = try container.decodeIfPresent(String.self, forKey: .koapEntityDescription)
        attachedImageUris = try container.decodeIfPresent([String].self, forKey: .attachedImageUris)
        uniqueFineId = try container.decodeIfPresent(String.self, forKey: .uniqueFineId)
        discountEffectTitle = try container.decodeIfPresent(String.self, forKey: .discountEffectTitle)
        discountEffectCountDays = try container.decode(Int.self, forKey: .discountEffectCountDays)
        location = try container.decodeIfPresent(String.self, forKey: .location)

        let iso8601 = ISO8601DateFormatter()
        iso8601.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        creationDate = try FineDto.decodeDate(from: container, key: .creationDate, formatter: iso8601)
        violationDate = try FineDto.decodeDate(from: container, key: .violationDate, formatter: iso8601)
        payToDueDate = try FineDto.decodeDateRequired(from: container, key: .payToDueDate, formatter: iso8601)
    }

    private static func decodeDate(
        from container: KeyedDecodingContainer<CodingKeys>,
        key: CodingKeys,
        formatter: ISO8601DateFormatter
    ) throws -> Date? {
        guard let string = try container.decodeIfPresent(String.self, forKey: key) else { return nil }
        return formatter.date(from: string) ?? ISO8601DateFormatter().date(from: string)
    }

    private static func decodeDateRequired(
        from container: KeyedDecodingContainer<CodingKeys>,
        key: CodingKeys,
        formatter: ISO8601DateFormatter
    ) throws -> Date {
        let string = try container.decode(String.self, forKey: key)
        let fallback = ISO8601DateFormatter()
        if let date = formatter.date(from: string) ?? fallback.date(from: string) {
            return date
        }
        throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Invalid date: \(string)")
    }
}

// MARK: - Enums

enum FinesDocumentType: Int, Decodable {
    case sts = 0
    case vu = 1
    case passport = 2
    case snils = 3
    case rawid = 4
    case none = 5
}

enum PaidStatuses: Int, Decodable {
    case notPaid = 0
    case partiallyPaid = 1
    case paid = 2
}

enum PaymentInternalStatuses: Int, Decodable {
    case unknown = 0
    case paid = 1
    case charged = 2
}
