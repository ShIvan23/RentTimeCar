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
    private(set) var datesCount = 0
    private(set) var deliveryAddress = ""
    private(set) var returnAddress = ""
    private(set) var selectedOptions = [String]()
    private(set) var auto: Auto?

    // MARK: - Internal Methods

    func setSelectedDates(_ selectedDates: [Date]) {
        self.selectedDates = Date.convertArrayDatesToString(selectedDates) ?? ""
        self.datesCount = selectedDates.count
    }

    func setImageUrl(_ imageUrl: String) {
        self.imageUrl = imageUrl
    }

    func setAuto(_ auto: Auto) {
        self.auto = auto
    }

    func setAddresses(deliveryAddress: String, returnAddress: String) {
        self.deliveryAddress = deliveryAddress
        self.returnAddress = returnAddress
    }

    func setSelectedOptions(_ selectedOptions: [String]) {
        self.selectedOptions = selectedOptions
    }
}
