//
//  ClientRequest.swift
//  RentTimeCar
//

import Foundation

struct ClientRequestsResponse: Decodable {
    let requests: [ClientRequest]

    enum CodingKeys: String, CodingKey {
        case requests = "Requests"
    }
}

struct ClientRequest: Decodable {
    let id: Int
    let number: String
    let creationDate: String
    let service: String
    let dealTypeId: Int
    let approvalStatus: String
    let requestState: Int
    let requestWorkingState: Int
    let rejectStatus: String?
    let currentStep: String
    let steps: ClientRequestStepsWrapper

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case number = "Number"
        case creationDate = "CreationDate"
        case service = "Service"
        case dealTypeId = "DealTypeId"
        case approvalStatus = "ApprovalStatus"
        case requestState = "RequestState"
        case requestWorkingState = "RequestWorkingState"
        case rejectStatus = "RejectStatus"
        case currentStep = "CurrentStep"
        case steps = "Steps"
    }

    var rentInfo: ClientRentInfo? {
        for step in steps.steps {
            for field in step.fields where field.code == "условия-договора" && field.isComplex {
                return ClientRentInfo(jsonString: field.value)
            }
        }
        return nil
    }

    var isCompleted: Bool {
        let terminalSteps = ["Отмена", "Завершена", "Закрыт"]
        return terminalSteps.contains { currentStep.localizedCaseInsensitiveContains($0) }
    }
}

struct ClientRequestStepsWrapper: Decodable {
    let steps: [ClientRequestStep]

    enum CodingKeys: String, CodingKey {
        case steps = "Steps"
    }
}

struct ClientRequestStep: Decodable {
    let title: String
    let code: String
    let fields: [ClientRequestField]

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case code = "Code"
        case fields = "Fields"
    }
}

struct ClientRequestField: Decodable {
    let title: String
    let code: String
    let value: String
    let isComplex: Bool

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case code = "Code"
        case value = "Value"
        case isComplex = "IsComplex"
    }
}

// MARK: - ContractInfo

struct ClientRentInfo {
    let autoId: Int?
    let autoTitle: String?
    let dateFrom: Date?
    let dateTo: Date?
    let deliveryAddress: String?
    let territory: String?

    init(jsonString: String) {
        guard let data = jsonString.data(using: .utf8),
              let raw = try? JSONDecoder().decode(ClientRentInfoResponse.self, from: data) else {
            autoId = nil
            autoTitle = nil
            dateFrom = nil
            dateTo = nil
            deliveryAddress = nil
            territory = nil
            return
        }
        autoId = raw.auto?.autoId
        autoTitle = raw.auto?.autoTitle?
            .components(separatedBy: ",")
            .first?
            .trimmingCharacters(in: .whitespaces)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        dateFrom = formatter.date(from: raw.dateFrom ?? "")
        dateTo = formatter.date(from: raw.dateTo ?? "")
        let address = raw.deliveryAddress?.result?.trimmingCharacters(in: .whitespaces)
        deliveryAddress = (address?.isEmpty == false) ? address : nil
        territory = raw.usingTerritoryDict?.values.joined(separator: " ")
    }
}

private struct ClientRentInfoResponse: Decodable {
    let auto: ClientRentAutoInfo?
    let dateFrom: String?
    let dateTo: String?
    let deliveryAddress: ClientDeliveryAddress?
    let usingTerritoryDict: [String: String]?

    enum CodingKeys: String, CodingKey {
        case auto = "Auto"
        case dateFrom = "DateFrom"
        case dateTo = "DateTo"
        case deliveryAddress = "DeliveryAddress"
        case usingTerritoryDict = "UsingTerritoryDict"
    }
}

private struct ClientRentAutoInfo: Decodable {
    let autoId: Int?
    let autoTitle: String?

    enum CodingKeys: String, CodingKey {
        case autoId = "AutoId"
        case autoTitle = "AutoTitle"
    }
}

private struct ClientDeliveryAddress: Decodable {
    let result: String?

    enum CodingKeys: String, CodingKey {
        case result = "result"
    }
}
