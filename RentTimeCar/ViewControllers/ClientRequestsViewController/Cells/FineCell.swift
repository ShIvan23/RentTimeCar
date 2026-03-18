//
//  FineCell.swift
//  RentTimeCar
//

import PinLayout
import UIKit

final class FineCell: UICollectionViewCell {

    // MARK: - UI

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondaryBackground
        view.layer.cornerRadius = 12
        return view
    }()

    private let idLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .whiteTextColor
        return label
    }()

    private let sumLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .enabledMainButtonBorderColor
        label.textAlignment = .right
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryTextColor
        label.numberOfLines = 2
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryTextColor
        return label
    }()

    private let toPayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryTextColor
        label.textAlignment = .right
        return label
    }()

    // MARK: - Private Properties

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        performLayout()
    }

    // MARK: - Internal Methods

    func configure(with fine: FineDto) {
        idLabel.text = fine.vehicleGibddNumber ?? fine.uniqueFineId ?? "—"
        sumLabel.text = fine.sum.map { "\($0) ₽" } ?? "—"
        descriptionLabel.text = fine.koapEntityDescription ?? "—"

        if let date = fine.violationDate {
            dateLabel.text = Self.dateFormatter.string(from: date)
        } else {
            dateLabel.text = "—"
        }

        if let toPay = fine.toPaymentSum {
            toPayLabel.text = "К оплате: \(toPay) ₽"
        } else {
            toPayLabel.text = ""
        }
    }

    // MARK: - Private Methods

    private func setupView() {
        contentView.addSubview(containerView)
        containerView.addSubviews([idLabel, sumLabel, descriptionLabel, dateLabel, toPayLabel])
    }

    private func performLayout() {
        containerView.pin.all()

        let halfWidth = containerView.bounds.width / 2 - 16

        idLabel.pin
            .top(14)
            .left(16)
            .width(halfWidth)
            .sizeToFit(.width)

        sumLabel.pin
            .top(14)
            .right(16)
            .width(halfWidth)
            .sizeToFit(.width)

        descriptionLabel.pin
            .below(of: idLabel)
            .marginTop(8)
            .left(16)
            .right(16)
            .sizeToFit(.width)

        dateLabel.pin
            .below(of: descriptionLabel)
            .marginTop(6)
            .left(16)
            .width(halfWidth)
            .sizeToFit(.width)

        toPayLabel.pin
            .below(of: descriptionLabel)
            .marginTop(6)
            .right(16)
            .width(halfWidth)
            .sizeToFit(.width)
    }
}
