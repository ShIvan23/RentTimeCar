//
//  OrderConfirmService.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 09.01.2026.
//

import Foundation

final class OrderConfirmService {
    static let shared = OrderConfirmService()

    // MARK: - Init

    private init() {}

    // MARK: - Private Properties

    private(set) var imageUrl = ""
    private(set) var selectedDates = ""
    private(set) var deliveryAddress = ""
    private(set) var returnAddress = ""
    private(set) var selectedOptions = [String]()

    // MARK: - Internal Methods

    func setSelectedDates(_ selectedDates: [Date]) {
        self.selectedDates = Date.convertArrayDatesToString(selectedDates) ?? ""
    }

    func setImageUrl(_ imageUrl: String) {
        self.imageUrl = imageUrl
    }

    func setAddresses(deliveryAddress: String, returnAddress: String) {
        self.deliveryAddress = deliveryAddress
        self.returnAddress = returnAddress
    }

    func setSelectedOptions(_ selectedOptions: [String]) {
        self.selectedOptions = selectedOptions
    }
}
