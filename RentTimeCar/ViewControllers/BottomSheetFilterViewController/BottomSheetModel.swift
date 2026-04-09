//
//  BottomSheetModel.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 09.12.2025.
//

import Foundation

enum BottomSheetType {
    case sorting
    case autoType

    func makeModel() -> [FilterInfoAuto] {
        switch self {
        case .sorting:
            return FilterService.shared.sortingAuto
        case .autoType:
            return FilterService.shared.autoClassesCodes.values.map { $0 }
        }
    }
}
