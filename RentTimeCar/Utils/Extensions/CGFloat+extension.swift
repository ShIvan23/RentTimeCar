//
//  CGFloat+extension.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 15.10.2025.
//

import UIKit

let displayScale: CGFloat = UIScreen.main.scale

extension CGFloat {
    func roundToDisplayScale() -> CGFloat {
        return CGFloat(roundf(Float(self * displayScale))) / displayScale
    }

    /// round up according to display scale and pixel size
    func ceilToDisplayScale() -> CGFloat {
        return CGFloat(ceilf(Float(self * displayScale))) / displayScale
    }
}
