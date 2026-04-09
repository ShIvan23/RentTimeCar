//
//  UIEdgeInsets+Extension.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 15.10.2025.
//

import UIKit

extension UIEdgeInsets {
    init(edges: CGFloat) {
        self.init(top: edges, left: edges, bottom: edges, right: edges)
    }

    init(top: CGFloat = 0, bottom: CGFloat = 0) {
        self.init(top: top, left: 0, bottom: bottom, right: 0)
    }

    init(left: CGFloat = 0, right: CGFloat = 0) {
        self.init(top: 0, left: left, bottom: 0, right: right)
    }

    init(horizontal: CGFloat = 0, vertical: CGFloat = 0) {
        self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }

    var horizontal: CGFloat {
        left + right
    }

    var vertical: CGFloat {
        top + bottom
    }

    // Inverted insets.
    // E.g.: (2; 4; 5; 0) will be inverted as (-2; -4; -5; 0).
    var inverted: UIEdgeInsets {
        .init(top: -top, left: -left, bottom: -bottom, right: -right)
    }
}
