//
//  ContractPaymentHeaderCardView.swift
//  RentTimeCar
//

import PinLayout
import UIKit

final class ContractPaymentHeaderCardView: UIView {

    private let contractNumberLabel = Label(fontSize: 17, weight: .bold)
    private let carNameLabel = Label(fontSize: 15, textColor: .whiteTextColor, textAlignment: .natural)
    private let datesLabel = Label(fontSize: 14, textColor: .secondaryTextColor, textAlignment: .natural)

    private let statusBadgeLabel: BadgeLabel = {
        let l = BadgeLabel()
        l.font = UIFont.openSans(fontSize: 13, weight: .semibold)
        l.textAlignment = .center
        l.layer.cornerRadius = 10
        l.layer.masksToBounds = true
        return l
    }()

    init(contractNumber: String, carName: String, dateFrom: Date, dateTo: Date, statusTitle: String, statusColor: UIColor) {
        super.init(frame: .zero)
        backgroundColor = .secondaryBackground
        layer.cornerRadius = 12

        contractNumberLabel.text = "Договор №\(contractNumber)"
        carNameLabel.text = carName
        datesLabel.text = Self.formatDateRange(from: dateFrom, to: dateTo)

        statusBadgeLabel.text = statusTitle
        statusBadgeLabel.textColor = statusColor
        statusBadgeLabel.backgroundColor = statusColor.withAlphaComponent(0.15)

        addSubview(contractNumberLabel)
        addSubview(statusBadgeLabel)
        addSubview(carNameLabel)
        addSubview(datesLabel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        let hPad: CGFloat = 16
        let vPad: CGFloat = 16

        statusBadgeLabel.pin.right(hPad).top(vPad).sizeToFit()
        contractNumberLabel.pin.left(hPad).top(vPad).before(of: statusBadgeLabel).marginRight(8).sizeToFit(.width)
        carNameLabel.pin.below(of: contractNumberLabel).marginTop(6).left(hPad).right(hPad).sizeToFit(.width)
        datesLabel.pin.below(of: carNameLabel).marginTop(4).left(hPad).right(hPad).sizeToFit(.width)

        let totalH = datesLabel.frame.maxY + vPad
        if frame.height != totalH { frame.size.height = totalH }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        frame = CGRect(origin: .zero, size: CGSize(width: size.width, height: 0))
        layoutSubviews()
        return CGSize(width: size.width, height: frame.height)
    }

    private static func formatDateRange(from: Date, to: Date) -> String {
        let cal = Calendar.current
        let dayFmt = DateFormatter()
        dayFmt.locale = Locale(identifier: "ru_RU")

        let days = max(cal.dateComponents([.day], from: from, to: to).day ?? 1, 1)
        let dayWord = daysWord(days)

        let fromComps = cal.dateComponents([.day, .month, .year], from: from)
        let toComps = cal.dateComponents([.day, .month, .year], from: to)

        if fromComps.month == toComps.month && fromComps.year == toComps.year {
            dayFmt.dateFormat = "d"
            let fromDay = dayFmt.string(from: from)
            dayFmt.dateFormat = "d MMMM yyyy"
            let toStr = dayFmt.string(from: to)
            return "\(fromDay) — \(toStr) · \(days) \(dayWord)"
        } else {
            dayFmt.dateFormat = "d MMMM"
            let fromStr = dayFmt.string(from: from)
            dayFmt.dateFormat = "d MMMM yyyy"
            let toStr = dayFmt.string(from: to)
            return "\(fromStr) — \(toStr) · \(days) \(dayWord)"
        }
    }

    private static func daysWord(_ n: Int) -> String {
        let mod10 = n % 10
        let mod100 = n % 100
        if mod100 >= 11 && mod100 <= 14 { return "дней" }
        switch mod10 {
        case 1: return "день"
        case 2, 3, 4: return "дня"
        default: return "дней"
        }
    }
}
