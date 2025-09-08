//
//  Array+Extension.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 08.09.2025.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        index >= 0 && index < count ? self[index] : nil
    }
}
