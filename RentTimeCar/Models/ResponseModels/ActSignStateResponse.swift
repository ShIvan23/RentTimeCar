//
//  ActSignStateResponse.swift
//  RentTimeCar
//

import Foundation

enum ActSignState: Int, Decodable {
    case unknown    = 0
    case notSigned  = 1
    case signedDigit = 2
    case signedPaper = 3

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(Int.self)
        self = ActSignState(rawValue: raw) ?? .unknown
    }
}

enum ActStates: Int, Decodable {
    case none      = 0
    case selected  = 1
    case inProgress = 2
    case finished  = 3
    case canceled  = 4
    case aborted   = 5
    case draft     = 6
    case unknown   = -1

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(Int.self)
        self = ActStates(rawValue: raw) ?? .unknown
    }
}

struct ActSignStateResponse: Decodable {
    let actSignState: ActSignState
    let actState: ActStates
}
