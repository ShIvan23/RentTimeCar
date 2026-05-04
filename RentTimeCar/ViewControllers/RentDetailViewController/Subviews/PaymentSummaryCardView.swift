//
//  PaymentSummaryCardView.swift
//  RentTimeCar
//

import PinLayout
import UIKit

final class PaymentSummaryCardView: UIView {

    struct Row {
        let title: String
        let value: String
        let highlighted: Bool
    }

    private var rowPairs: [(title: UILabel, value: UILabel)] = []

    init(rows: [Row]) {
        super.init(frame: .zero)
        backgroundColor = .secondaryBackground
        layer.cornerRadius = 12

        for row in rows {
            let titleLabel = UILabel()
            titleLabel.text = row.title
            titleLabel.font = .systemFont(ofSize: 14)
            titleLabel.textColor = .secondaryTextColor

            let valueLabel = UILabel()
            valueLabel.text = row.value
            valueLabel.font = .systemFont(ofSize: 14, weight: .medium)
            valueLabel.textColor = row.highlighted ? .systemRed : .whiteTextColor
            valueLabel.textAlignment = .right

            addSubview(titleLabel)
            addSubview(valueLabel)
            rowPairs.append((titleLabel, valueLabel))
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()

        let hPad: CGFloat = 16
        let vPad: CGFloat = 16
        let rowSpacing: CGFloat = 10

        var y: CGFloat = vPad
        for pair in rowPairs {
            pair.value.pin.right(hPad).top(y).sizeToFit()
            pair.title.pin.left(hPad).top(y).before(of: pair.value).marginRight(8).sizeToFit(.width)
            let rowH = max(pair.title.frame.height, pair.value.frame.height)
            y += rowH + rowSpacing
        }
        let totalH = y - rowSpacing + vPad
        if frame.height != totalH { frame.size.height = totalH }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        frame = CGRect(origin: .zero, size: CGSize(width: size.width, height: 0))
        layoutSubviews()
        return CGSize(width: size.width, height: frame.height)
    }
}
