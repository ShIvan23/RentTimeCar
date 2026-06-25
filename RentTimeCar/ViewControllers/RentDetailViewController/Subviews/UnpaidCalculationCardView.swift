//
//  UnpaidCalculationCardView.swift
//  RentTimeCar
//

import PinLayout
import UIKit

final class UnpaidCalculationCardView: UIView {

    private let titleLabel = UILabel()
    private let sumLabel = UILabel()
    private let dateLabel = UILabel()

    init(calculation: MoneyCalculation) {
        super.init(frame: .zero)
        backgroundColor = .secondaryBackground
        layer.cornerRadius = 10

        let name = calculation.subCategory.isEmpty ? calculation.categoryTitle : calculation.subCategory
        titleLabel.text = name
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .whiteTextColor
        addSubview(titleLabel)

        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.groupingSeparator = "\u{202F}"
        fmt.maximumFractionDigits = 2
        fmt.minimumFractionDigits = 0
        let amount = abs(calculation.toPaymentSum)
        let str = fmt.string(from: amount as NSDecimalNumber) ?? "0"
        sumLabel.text = "\(str) ₽"
        sumLabel.textColor = .systemOrange
        sumLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        sumLabel.textAlignment = .right
        addSubview(sumLabel)

        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "dd.MM.yyyy"
        dateFmt.locale = Locale(identifier: "ru_RU")
        dateLabel.text = dateFmt.string(from: calculation.accountingDate)
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .secondaryTextColor
        addSubview(dateLabel)
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
        let totalH = dateLabel.frame.maxY + vPad
        if frame.height != totalH { frame.size.height = totalH }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        frame = CGRect(origin: .zero, size: CGSize(width: size.width, height: 0))
        layoutSubviews()
        return CGSize(width: size.width, height: frame.height)
    }
}
