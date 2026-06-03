//
//  FeatureFlagService.swift
//  RentTimeCar
//

import Foundation

final class FeatureFlagService {
    static let shared = FeatureFlagService()
    private init() {}

    private(set) var hidePayments: Bool = false

    func apply(_ flags: FeatureFlags?) {
        hidePayments = flags?.hidePayments ?? false
    }

    func applyReviewMode() {
        hidePayments = true
    }
}
