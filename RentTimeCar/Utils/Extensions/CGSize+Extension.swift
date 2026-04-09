//
//  CGSize+Extension.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 30.07.2025.
//

import UIKit

extension CGSize {
    init(square: CGFloat) {
        self.init(width: square, height: square)
    }
}

extension CGSize {
    static func textSize(for text: String, maxWidth: CGFloat, maxHeight: CGFloat = .greatestFiniteMagnitude) -> CGSize {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.openSans() ?? .systemFont(ofSize: 16)
        ]

        let attributedText = NSAttributedString(string: text, attributes: attributes)

        let constraintBox = CGSize(width: maxWidth, height: maxHeight)
        let rect = attributedText.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading, .truncatesLastVisibleLine], context: nil).integral

        return rect.size
    }
}
