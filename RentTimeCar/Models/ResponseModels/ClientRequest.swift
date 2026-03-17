//
//  ClientRequest.swift
//  RentTimeCar
//

import Foundation

struct ClientRequest: Decodable {
    let id: Int
    let number: String
    let creationDate: String
    let service: String
    let dealTypeId: Int
    let approvalStatus: String
    let requestState: String
    let requestWorkingState: String
    let rejectStatus: String?
    let currentStep: String
    let steps: [ClientRequestStep]

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

struct ClientRequestStep: Decodable {
    // Поля шага будут добавлены по мере уточнения API
}
