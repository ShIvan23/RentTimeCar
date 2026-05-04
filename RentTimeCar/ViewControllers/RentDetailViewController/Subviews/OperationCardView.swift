//
//  OperationCardView.swift
//  RentTimeCar
//

import PinLayout
import UIKit

final class OperationCardView: UIView {

    private let titleLabel = UILabel()
    private let sumLabel = UILabel()
    private let dateLabel = UILabel()
    private let separatorView = UIView()
    private var subItemPairs: [(desc: UILabel, sum: UILabel)] = []

    init(operation: MoneyOperation) {
        super.init(frame: .zero)
        backgroundColor = .secondaryBackground
        layer.cornerRadius = 10

        let fmt = Self.makeFormatter()

        titleLabel.text = operation.operationTypeTitle
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .whiteTextColor
        addSubview(titleLabel)

        if operation.sum != 0 {
            switch operation.direction {
            case 1: sumLabel.text = "+\(fmt(operation.sum))"; sumLabel.textColor = .systemGreen
            case 2: sumLabel.text = "-\(fmt(operation.sum))"; sumLabel.textColor = .systemRed
            default: sumLabel.text = fmt(operation.sum); sumLabel.textColor = .whiteTextColor
            }
        }
        sumLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        sumLabel.textAlignment = .right
        addSubview(sumLabel)

        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "dd.MM.yyyy"
        dateFmt.locale = Locale(identifier: "ru_RU")
        dateLabel.text = dateFmt.string(from: operation.accountingDate)
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .secondaryTextColor
        addSubview(dateLabel)

        let subItems: [(desc: String, amount: String, sum: Decimal, direction: Int)] =
            !operation.calculations.isEmpty
                ? operation.calculations.map { ($0.description, $0.amountTitle, $0.sum, $0.direction) }
                : operation.payments.map { ($0.description, $0.amountTitle, $0.sum, $0.direction) }

        if !subItems.isEmpty {
            separatorView.backgroundColor = UIColor.white.withAlphaComponent(0.07)
            addSubview(separatorView)

            for item in subItems {
                let descLabel = UILabel()
                let amountPart = item.amount.trimmingCharacters(in: .whitespaces)
                descLabel.text = amountPart.isEmpty ? item.desc : "\(item.desc) · \(amountPart)"
                descLabel.font = .systemFont(ofSize: 12)
                descLabel.textColor = .secondaryTextColor
                descLabel.numberOfLines = 2
                addSubview(descLabel)

                let itemSumLabel = UILabel()
                if item.sum != 0 {
                    switch item.direction {
                    case 2: itemSumLabel.text = "-\(fmt(item.sum))"; itemSumLabel.textColor = .systemRed
                    default: itemSumLabel.text = fmt(item.sum); itemSumLabel.textColor = .secondaryTextColor
                    }
                }
                itemSumLabel.font = .systemFont(ofSize: 12)
                itemSumLabel.textAlignment = .right
                addSubview(itemSumLabel)

                subItemPairs.append((descLabel, itemSumLabel))
            }
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()

        let hPad: CGFloat = 16
        let vPad: CGFloat = 12

        sumLabel.pin.right(hPad).top(vPad).sizeToFit()
        titleLabel.pin.left(hPad).top(vPad).before(of: sumLabel).marginRight(8).sizeToFit(.width)
        dateLabel.pin.below(of: titleLabel).marginTop(4).left(hPad).sizeToFit()

        var currentY = dateLabel.frame.maxY

        if !subItemPairs.isEmpty {
            separatorView.pin.top(currentY + 10).horizontally(hPad).height(1)
            currentY = separatorView.frame.maxY

            for pair in subItemPairs {
                currentY += 6
                pair.sum.pin.right(hPad).top(currentY).sizeToFit()
                pair.desc.pin.left(hPad).top(currentY).before(of: pair.sum).marginRight(8).sizeToFit(.width)
                currentY = max(pair.desc.frame.maxY, pair.sum.frame.maxY)
            }
        }

        let totalH = currentY + vPad
        if frame.height != totalH { frame.size.height = totalH }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        frame = CGRect(origin: .zero, size: CGSize(width: size.width, height: 0))
        layoutSubviews()
        return CGSize(width: size.width, height: frame.height)
    }

    private static func makeFormatter() -> (Decimal) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.groupingSeparator = "\u{202F}"
        fmt.maximumFractionDigits = 2
        fmt.minimumFractionDigits = 0
        return { decimal in
            let str = fmt.string(from: decimal as NSDecimalNumber) ?? "0"
            return "\(str) ₽"
        }
    }
}
