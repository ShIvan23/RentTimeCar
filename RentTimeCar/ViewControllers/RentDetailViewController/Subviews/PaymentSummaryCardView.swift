//
//  PaymentSummaryCardView.swift
//  RentTimeCar
//

import PinLayout
import UIKit

final class PaymentSummaryCardView: UIView {

    private let sectionTitleLabel: Label = {
        let l = Label(text: "РАСЧЁТ ПО ДОГОВОРУ", fontSize: 11, weight: .semibold, textColor: .secondaryTextColor, textAlignment: .natural)
        l.letterSpacing(1.2)
        return l
    }()

    private let chargedTitleLabel = Label(text: "Начислено", fontSize: 15, textColor: .whiteTextColor, textAlignment: .natural)
    private let chargedValueLabel = Label(fontSize: 15, weight: .semibold, textAlignment: .right)

    private let paidTitleLabel = Label(text: "Оплачено", fontSize: 15, textColor: .whiteTextColor, textAlignment: .natural)
    private let paidValueLabel = Label(fontSize: 15, weight: .semibold, textAlignment: .right)

    private let dividerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        return v
    }()

    private let balanceTitleLabel = Label(text: "Баланс", fontSize: 15, weight: .semibold, textColor: .whiteTextColor, textAlignment: .natural)
    private let balanceValueLabel = Label(fontSize: 15, weight: .bold, textAlignment: .right)

    private let subtitleLabel = Label(fontSize: 12, textColor: .secondaryTextColor, textAlignment: .natural)

    init(charged: String, paid: String, balance: Decimal, subtitle: String? = nil, fmt: (Decimal) -> String) {
        super.init(frame: .zero)
        backgroundColor = .secondaryBackground
        layer.cornerRadius = 12

        chargedValueLabel.text = charged
        chargedValueLabel.textColor = .whiteTextColor

        paidValueLabel.text = paid
        paidValueLabel.textColor = .systemGreen

        let balanceStr = fmt(abs(balance))
        if balance < 0 {
            balanceValueLabel.text = "–\(balanceStr)"
            balanceValueLabel.textColor = .systemRed
        } else if balance == 0 {
            balanceValueLabel.text = "0 ₽"
            balanceValueLabel.textColor = .systemGreen
        } else {
            balanceValueLabel.text = balanceStr
            balanceValueLabel.textColor = .systemGreen
        }

        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil
        subtitleLabel.numberOfLines = 0

        addSubview(sectionTitleLabel)
        addSubview(chargedTitleLabel)
        addSubview(chargedValueLabel)
        addSubview(paidTitleLabel)
        addSubview(paidValueLabel)
        addSubview(dividerView)
        addSubview(balanceTitleLabel)
        addSubview(balanceValueLabel)
        addSubview(subtitleLabel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        let hPad: CGFloat = 16
        let vPad: CGFloat = 16
        let rowSpacing: CGFloat = 12

        sectionTitleLabel.pin.top(vPad).horizontally(hPad).sizeToFit(.width)

        var y = sectionTitleLabel.frame.maxY + 14

        chargedValueLabel.pin.right(hPad).top(y).sizeToFit()
        chargedTitleLabel.pin.left(hPad).top(y).before(of: chargedValueLabel).marginRight(8).sizeToFit(.width)
        y += max(chargedTitleLabel.frame.height, chargedValueLabel.frame.height) + rowSpacing

        paidValueLabel.pin.right(hPad).top(y).sizeToFit()
        paidTitleLabel.pin.left(hPad).top(y).before(of: paidValueLabel).marginRight(8).sizeToFit(.width)
        y += max(paidTitleLabel.frame.height, paidValueLabel.frame.height) + rowSpacing

        dividerView.pin.top(y).horizontally(hPad).height(1)
        y = dividerView.frame.maxY + rowSpacing

        balanceValueLabel.pin.right(hPad).top(y).sizeToFit()
        balanceTitleLabel.pin.left(hPad).top(y).before(of: balanceValueLabel).marginRight(8).sizeToFit(.width)
        y += max(balanceTitleLabel.frame.height, balanceValueLabel.frame.height)

        if !subtitleLabel.isHidden {
            subtitleLabel.pin.top(y + 6).horizontally(hPad).sizeToFit(.width)
            y = subtitleLabel.frame.maxY
        }

        let totalH = y + vPad
        if frame.height != totalH { frame.size.height = totalH }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        frame = CGRect(origin: .zero, size: CGSize(width: size.width, height: 0))
        layoutSubviews()
        return CGSize(width: size.width, height: frame.height)
    }
}

private extension Label {
    func letterSpacing(_ spacing: CGFloat) {
        guard let text else { return }
        attributedText = NSAttributedString(string: text, attributes: [.kern: spacing, .font: font as Any])
    }
}
