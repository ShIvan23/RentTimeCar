//
//  CalculationItemView.swift
//  RentTimeCar
//

import PinLayout
import UIKit

final class CalculationItemView: UIView {

    enum Badge {
        case paid
        case paidFromDeposit
        case none
    }

    private let titleLabel: Label = {
        let l = Label(fontSize: 15, weight: .medium, textAlignment: .natural)
        l.numberOfLines = 2
        return l
    }()

    private let subtitleLabel = Label(fontSize: 13, textColor: .secondaryTextColor, textAlignment: .natural)

    private let badgeLabel: BadgeLabel = {
        let l = BadgeLabel()
        l.font = UIFont.openSans(fontSize: 13, weight: .medium)
        l.textAlignment = .center
        l.layer.cornerRadius = 11
        l.layer.masksToBounds = true
        return l
    }()

    private let amountLabel = Label(fontSize: 15, weight: .semibold, textAlignment: .right)

    init(title: String, subtitle: String?, badge: Badge, amount: String, amountColor: UIColor) {
        super.init(frame: .zero)

        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil || subtitle!.isEmpty
        amountLabel.text = amount
        amountLabel.textColor = amountColor

        switch badge {
        case .paid:
            badgeLabel.text = "Оплачено"
            badgeLabel.textColor = .systemGreen
            badgeLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
            badgeLabel.isHidden = false
        case .paidFromDeposit:
            badgeLabel.text = "Оплачено из залога"
            badgeLabel.textColor = .systemBlue
            badgeLabel.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
            badgeLabel.isHidden = false
        case .none:
            badgeLabel.isHidden = true
        }

        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(badgeLabel)
        addSubview(amountLabel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        let hPad: CGFloat = 16
        let vPad: CGFloat = 14

        amountLabel.pin.right(hPad).top(vPad).sizeToFit()
        titleLabel.pin.left(hPad).top(vPad).before(of: amountLabel).marginRight(8).sizeToFit(.width)

        var y = max(titleLabel.frame.maxY, amountLabel.frame.maxY)

        if !subtitleLabel.isHidden {
            subtitleLabel.pin.left(hPad).top(y + 4).right(hPad).sizeToFit(.width)
            y = subtitleLabel.frame.maxY
        }

        if !badgeLabel.isHidden {
            badgeLabel.pin.left(hPad).top(y + 6).sizeToFit()
            y = badgeLabel.frame.maxY
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
