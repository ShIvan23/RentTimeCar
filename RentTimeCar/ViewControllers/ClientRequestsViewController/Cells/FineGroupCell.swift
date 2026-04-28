//
//  FineGroupCell.swift
//  RentTimeCar
//

import Nuke
import NukeExtensions
import PinLayout
import UIKit

// MARK: - FineGroup

struct FineGroup {
    let vehicle: String?
    let contractNumber: String?
    let fines: [FineDto]

    var totalSum: Decimal {
        fines.compactMap(\.sum).reduce(0, +)
    }

    var dateRange: String? {
        let dates = fines.compactMap(\.violationDate).sorted()
        guard let first = dates.first, let last = dates.last else { return nil }
        let dayMonth = DateFormatter()
        dayMonth.dateFormat = "dd.MM"
        let year = DateFormatter()
        year.dateFormat = "yyyy"
        if first == last {
            let full = DateFormatter()
            full.dateFormat = "dd.MM.yyyy"
            return full.string(from: first)
        }
        return "\(dayMonth.string(from: first))-\(dayMonth.string(from: last)).\(year.string(from: last))"
    }

    var isPaid: Bool {
        !fines.isEmpty && fines.allSatisfy { $0.gibddStatus == .paid }
    }
}

// MARK: - FineGroupCell

final class FineGroupCell: UICollectionViewCell {

    // MARK: - Constants

    static let headerHeight: CGFloat = 88
    static let rowHeight: CGFloat = 56
    private static let separatorH: CGFloat = 1

    static func height(fineCount: Int, isExpanded: Bool) -> CGFloat {
        isExpanded ? headerHeight + separatorH + rowHeight * CGFloat(fineCount) : headerHeight
    }

    // MARK: - Callback

    var onToggle: (() -> Void)?

    // MARK: - Private state

    private var fineRows: [FineRowView] = []

    // MARK: - UI

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .secondaryBackground
        v.layer.cornerRadius = 12
        v.clipsToBounds = true
        return v
    }()

    private let carImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.backgroundColor = .mainBackground
        return iv
    }()

    private let carNameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.textColor = .whiteTextColor
        return l
    }()

    private let countBadgeLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = .whiteTextColor
        l.textAlignment = .center
        l.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        l.layer.cornerRadius = 10
        l.clipsToBounds = true
        return l
    }()

    private let paidIconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let sumDateLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        return l
    }()

    private let chevronImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.down")
        iv.tintColor = .secondaryTextColor
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let separatorView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        return v
    }()

    // MARK: - Number formatter

    private static let numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        f.groupingSize = 3
        f.usesGroupingSeparator = true
        f.groupingSeparator = " "
        return f
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        performLayout()
    }

    // MARK: - Configure

    func configure(group: FineGroup, isExpanded: Bool) {
        let greenColor = UIColor(red: 0.3, green: 0.65, blue: 0.35, alpha: 1)

        carNameLabel.text = group.vehicle ?? "Автомобиль"
        countBadgeLabel.text = "  \(group.fines.count)  "

        let isPaid = group.isPaid
        let statusColor = isPaid ? greenColor : UIColor.secondaryTextColor
        paidIconView.image = UIImage(systemName: isPaid ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
        paidIconView.tintColor = statusColor
        sumDateLabel.textColor = statusColor

        let sumStr = Self.numberFormatter.string(from: group.totalSum as NSDecimalNumber) ?? "\(group.totalSum)"
        let dateStr = group.dateRange ?? ""
        sumDateLabel.text = dateStr.isEmpty ? "\(sumStr) ₽" : "\(sumStr) ₽ • \(dateStr)"

        chevronImageView.transform = isExpanded ? CGAffineTransform(rotationAngle: .pi) : .identity
        separatorView.isHidden = !isExpanded

        fineRows.forEach { $0.removeFromSuperview() }
        fineRows = []

        if isExpanded {
            for fine in group.fines {
                let row = FineRowView()
                row.configure(fine: fine, formatter: Self.numberFormatter)
                containerView.addSubview(row)
                fineRows.append(row)
            }
        }

        carImageView.image = .carPlaceholder
        if let vehicleName = group.vehicle {
            let searchKey = vehicleName.components(separatedBy: ",").first ?? vehicleName
            let matched = FilterService.shared.allAutos.first {
                $0.title.localizedCaseInsensitiveContains(searchKey)
            }
            if let urlString = matched?.files.first(where: { $0.url != nil && $0.folder == .folderImageValue })?.url,
               let url = URL(string: urlString) {
                let options = ImageLoadingOptions(placeholder: .carPlaceholder, transition: .fadeIn(duration: 0.2))
                NukeExtensions.loadImage(with: url, options: options, into: carImageView)
            }
        }

        setNeedsLayout()
    }

    // MARK: - Private

    private func setupView() {
        contentView.addSubview(containerView)
        containerView.addSubviews([
            carImageView, carNameLabel, countBadgeLabel,
            paidIconView, sumDateLabel, chevronImageView,
            separatorView
        ])
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
    }

    @objc private func tapped() {
        onToggle?()
    }

    private func performLayout() {
        containerView.pin.all()

        let imgSize: CGFloat = 60
        let hPad: CGFloat = 12
        let imgTop = (Self.headerHeight - imgSize) / 2

        carImageView.pin
            .left(hPad)
            .top(imgTop)
            .size(imgSize)

        let contentLeft = carImageView.frame.maxX + 10

        chevronImageView.pin
            .right(hPad)
            .vCenter(to: carImageView.edge.vCenter)
            .size(18)

        carNameLabel.pin
            .top(18)
            .left(contentLeft)
            .right(chevronImageView.frame.width + hPad + 8)
            .sizeToFit(.width)

        countBadgeLabel.pin
            .after(of: carNameLabel, aligned: .center)
            .marginLeft(6)
            .height(20)
            .sizeToFit(.width)

        paidIconView.pin
            .below(of: carNameLabel)
            .marginTop(6)
            .left(contentLeft)
            .size(16)

        sumDateLabel.pin
            .after(of: paidIconView, aligned: .center)
            .marginLeft(4)
            .right(chevronImageView.frame.width + hPad + 8)
            .sizeToFit(.width)

        separatorView.pin
            .top(Self.headerHeight)
            .horizontally(hPad)
            .height(Self.separatorH)

        var rowY = Self.headerHeight + Self.separatorH
        for row in fineRows {
            row.pin
                .top(rowY)
                .horizontally()
                .height(Self.rowHeight)
            rowY += Self.rowHeight
        }
    }
}

// MARK: - FineRowView

private final class FineRowView: UIView {

    private let checkIconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let sumLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .medium)
        l.textColor = .whiteTextColor
        return l
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryTextColor
        return l
    }()

    private let arrowImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right")
        iv.tintColor = .secondaryTextColor
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let bottomSeparator: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        return v
    }()

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd.MM.yyyy"
        return f
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews([checkIconView, sumLabel, dateLabel, arrowImageView, bottomSeparator])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(fine: FineDto, formatter: NumberFormatter) {
        let isPaid = fine.gibddStatus == .paid
        let greenColor = UIColor(red: 0.3, green: 0.65, blue: 0.35, alpha: 1)
        checkIconView.image = UIImage(systemName: isPaid ? "checkmark.circle.fill" : "circle")
        checkIconView.tintColor = isPaid ? greenColor : .secondaryTextColor

        let sumStr = fine.sum.flatMap { formatter.string(from: $0 as NSDecimalNumber) } ?? "—"
        sumLabel.text = "\(sumStr) ₽"

        if let date = fine.violationDate {
            dateLabel.text = "Дата: \(Self.dateFormatter.string(from: date))"
        } else {
            dateLabel.text = "—"
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let hPad: CGFloat = 16

        checkIconView.pin
            .left(hPad)
            .vCenter()
            .size(20)

        arrowImageView.pin
            .right(hPad)
            .vCenter()
            .size(14)

        sumLabel.pin
            .after(of: checkIconView)
            .marginLeft(10)
            .right(arrowImageView.frame.width + hPad + 8)
            .top(12)
            .sizeToFit(.width)

        dateLabel.pin
            .below(of: sumLabel)
            .marginTop(2)
            .left(sumLabel.frame.minX)
            .right(arrowImageView.frame.width + hPad + 8)
            .sizeToFit(.width)

        bottomSeparator.pin
            .bottom()
            .horizontally(hPad)
            .height(1)
    }
}
