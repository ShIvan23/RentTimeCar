//
//  CGRect+Extension.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 15.10.2025.
//

import Foundation

extension CGRect {
    init(minX: CGFloat, minY: CGFloat, maxX: CGFloat, maxY: CGFloat) {
        self.init(
            origin: CGPoint(x: minX, y: minY),
            size: CGSize(
                width: maxX - minX,
                height: maxY - minY
            )
        )
    }

    init(minX: CGFloat, minY: CGFloat, size: CGSize) {
        self.init(x: minX, y: minY, width: size.width, height: size.height)
    }

    init(maxX: CGFloat, minY: CGFloat, size: CGSize) {
        self.init(x: maxX - size.width, y: minY, width: size.width, height: size.height)
    }

    init(midX: CGFloat, minY: CGFloat, size: CGSize) {
        self.init(x: midX - size.width / 2, y: minY, width: size.width, height: size.height)
    }

    init(minX: CGFloat, midY: CGFloat, size: CGSize) {
        self.init(x: minX, y: midY - size.height / 2, width: size.width, height: size.height)
    }

    init(minX: CGFloat, maxY: CGFloat, size: CGSize) {
        self.init(x: minX, y: maxY - size.height, width: size.width, height: size.height)
    }
}
