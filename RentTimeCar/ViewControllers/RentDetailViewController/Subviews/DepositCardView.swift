//
//  DepositCardView.swift
//  RentTimeCar
//

import PinLayout
import UIKit

final class DepositCardView: UIView {

    private let titleLabel = Label(text: "Залог (депозит)", fontSize: 16, weight: .bold, textAlignment: .natural)

    private let badgeLabel: BadgeLabel = {
        let l = BadgeLabel()
        l.text = "Возврат по истечении 15 дней"
        l.font = UIFont.openSans(fontSize: 12, weight: .medium)
        l.textAlignment = .center
        l.textColor = UIColor(red: 0.9, green: 0.7, blue: 0.1, alpha: 1)
        l.backgroundColor = UIColor(red: 0.9, green: 0.7, blue: 0.1, alpha: 0.15)
        l.layer.cornerRadius = 10
        l.layer.masksToBounds = true
        return l
    }()

    private let depositedTitleLabel = Label(text: "Внесено", fontSize: 14, textColor: .secondaryTextColor, textAlignment: .natural)
    private let depositedValueLabel = Label(fontSize: 14, weight: .semibold, textAlignment: .right)

    private let spentTitleLabel = Label(text: "Списано в счёт услуг", fontSize: 14, textColor: .secondaryTextColor, textAlignment: .natural)
    private let spentValueLabel = Label(fontSize: 14, weight: .semibold, textAlignment: .right)

    private let remainingTitleLabel = Label(text: "Остаток к возврату", fontSize: 14, textColor: .secondaryTextColor, textAlignment: .natural)
    private let remainingValueLabel: Label = {
        let l = Label(fontSize: 14, weight: .semibold, textColor: .systemGreen, textAlignment: .right)
        return l
    }()

    private let descriptionLabel = Label(
        text: "Залог вносится перед началом аренды и возвращается по истечении 15 дней после закрытия договора при отсутствии штрафов и повреждений.",
        numberOfLines: 0,
        fontSize: 12,
        textColor: .secondaryTextColor,
        textAlignment: .natural
    )

    init(deposited: String, spent: String, remaining: String) {
        super.init(frame: .zero)
        backgroundColor = .secondaryBackground
        layer.cornerRadius = 12
        layer.borderWidth = 1.5
        layer.borderColor = UIColor(red: 0.9, green: 0.7, blue: 0.1, alpha: 0.5).cgColor

        depositedValueLabel.text = deposited
        depositedValueLabel.textColor = .whiteTextColor
        spentValueLabel.text = spent
        spentValueLabel.textColor = .whiteTextColor
        remainingValueLabel.text = remaining

        addSubview(titleLabel)
        addSubview(badgeLabel)
        addSubview(depositedTitleLabel)
        addSubview(depositedValueLabel)
        addSubview(spentTitleLabel)
        addSubview(spentValueLabel)
        addSubview(remainingTitleLabel)
        addSubview(remainingValueLabel)
        addSubview(descriptionLabel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        let hPad: CGFloat = 16
        let vPad: CGFloat = 16
        let rowSpacing: CGFloat = 10

        titleLabel.pin.top(vPad).left(hPad).sizeToFit()
        badgeLabel.pin.right(hPad).vCenter(to: titleLabel.edge.vCenter).sizeToFit()

        var y = titleLabel.frame.maxY + 14

        depositedValueLabel.pin.right(hPad).top(y).sizeToFit()
        depositedTitleLabel.pin.left(hPad).top(y).before(of: depositedValueLabel).marginRight(8).sizeToFit(.width)
        y += max(depositedTitleLabel.frame.height, depositedValueLabel.frame.height) + rowSpacing

        spentValueLabel.pin.right(hPad).top(y).sizeToFit()
        spentTitleLabel.pin.left(hPad).top(y).before(of: spentValueLabel).marginRight(8).sizeToFit(.width)
        y += max(spentTitleLabel.frame.height, spentValueLabel.frame.height) + rowSpacing

        remainingValueLabel.pin.right(hPad).top(y).sizeToFit()
        remainingTitleLabel.pin.left(hPad).top(y).before(of: remainingValueLabel).marginRight(8).sizeToFit(.width)
        y += max(remainingTitleLabel.frame.height, remainingValueLabel.frame.height) + 12

        descriptionLabel.pin.top(y).horizontally(hPad).sizeToFit(.width)

        let totalH = descriptionLabel.frame.maxY + vPad
        if frame.height != totalH { frame.size.height = totalH }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        frame = CGRect(origin: .zero, size: CGSize(width: size.width, height: 0))
        layoutSubviews()
        return CGSize(width: size.width, height: frame.height)
    }
}
