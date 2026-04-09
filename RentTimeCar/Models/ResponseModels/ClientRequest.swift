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
}

struct ClientRequestStepsWrapper: Decodable {
    let steps: [ClientRequestStep]

    enum CodingKeys: String, CodingKey {
        case steps = "Steps"
    }
}

struct ClientRequestStep: Decodable {
    // Поля шага будут добавлены по мере уточнения API
}
