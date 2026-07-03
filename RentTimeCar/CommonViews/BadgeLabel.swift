//
//  BadgeLabel.swift
//  RentTimeCar
//

import UIKit

final class BadgeLabel: UILabel {

    var contentInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10) {
        didSet { invalidateIntrinsicContentSize() }
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInsets))
    }

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += contentInsets.left + contentInsets.right
        size.height += contentInsets.top + contentInsets.bottom
        return size
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var s = super.sizeThatFits(
            CGSize(width: size.width - contentInsets.left - contentInsets.right,
                   height: size.height - contentInsets.top - contentInsets.bottom)
        )
        s.width += contentInsets.left + contentInsets.right
        s.height += contentInsets.top + contentInsets.bottom
        return s
    }
}
