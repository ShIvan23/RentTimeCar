//
//  ClientRequestCell.swift
//  RentTimeCar
//

import PinLayout
import UIKit

final class ClientRequestCell: UICollectionViewCell {

    // MARK: - UI

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondaryBackground
        view.layer.cornerRadius = 12
        return view
    }()

    private let numberLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .whiteTextColor
        return label
    }()

    private let serviceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryTextColor
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryTextColor
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .enabledMainButtonBorderColor
        label.textAlignment = .right
        return label
    }()

    private let currentStepLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryTextColor
        label.textAlignment = .right
        return label
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

    func configure(with model: ClientRequest) {
        numberLabel.text = model.number
        serviceLabel.text = model.service
        statusLabel.text = model.approvalStatus
        currentStepLabel.text = model.currentStep
        dateLabel.text = String(model.creationDate.prefix(10))
    }

    // MARK: - Private Methods

    private func setupView() {
        contentView.addSubview(containerView)
        containerView.addSubviews([numberLabel, serviceLabel, dateLabel, statusLabel, currentStepLabel])
    }

    private func performLayout() {
        containerView.pin.all()

        numberLabel.pin
            .top(16)
            .left(16)
            .width(containerView.bounds.width / 2 - 16)
            .sizeToFit(.width)

        statusLabel.pin
            .top(16)
            .right(16)
            .width(containerView.bounds.width / 2 - 16)
            .sizeToFit(.width)

        serviceLabel.pin
            .below(of: numberLabel)
            .marginTop(8)
            .left(16)
            .right(16)
            .sizeToFit(.width)

        dateLabel.pin
            .below(of: serviceLabel)
            .marginTop(6)
            .left(16)
            .width(containerView.bounds.width / 2 - 16)
            .sizeToFit(.width)

        currentStepLabel.pin
            .below(of: serviceLabel)
            .marginTop(6)
            .right(16)
            .width(containerView.bounds.width / 2 - 16)
            .sizeToFit(.width)
    }
}
