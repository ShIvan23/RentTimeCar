//
//  ClientRequestCell.swift
//  RentTimeCar
//

import Nuke
import NukeExtensions
import PinLayout
import UIKit

final class ClientRequestCell: UICollectionViewCell {

    // MARK: - UI

    private let carImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        iv.backgroundColor = .secondaryBackground
        return iv
    }()

    private let carNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .whiteTextColor
        label.numberOfLines = 1
        return label
    }()

    private let dateFromLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryTextColor
        return label
    }()

    private let dateToLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryTextColor
        return label
    }()

    private let statusBadgeView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        view.clipsToBounds = true
        return view
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.transform = CGAffineTransform(rotationAngle: .pi / 2)
        return label
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondaryBackground
        view.layer.cornerRadius = 12
        return view
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
        let info = model.rentInfo
        carNameLabel.text = info?.autoTitle ?? model.service

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm, dd.MM.yy"
        dateFromLabel.text = info?.dateFrom.map { "От: \(formatter.string(from: $0))" } ?? "От: —"
        dateToLabel.text = info?.dateTo.map { "До: \(formatter.string(from: $0))" } ?? "До: —"

        statusLabel.text = model.currentStep
        configureStatusBadge(for: model.currentStep)
        loadCarImage(autoId: info?.autoId)
    }

    // MARK: - Private Methods

    private func setupView() {
        contentView.addSubview(containerView)
        containerView.addSubviews([carImageView, carNameLabel, dateFromLabel, dateToLabel, statusBadgeView])
        statusBadgeView.addSubview(statusLabel)
    }

    private func configureStatusBadge(for step: String) {
        let cancelledSteps = ["Отмена", "Отклонено", "Отклонён"]
        let completedSteps = ["Завершена", "Завершён", "Закрыт"]
        if cancelledSteps.contains(where: { step.localizedCaseInsensitiveContains($0) }) {
            statusBadgeView.backgroundColor = UIColor(red: 0.85, green: 0.25, blue: 0.25, alpha: 1)
        } else if completedSteps.contains(where: { step.localizedCaseInsensitiveContains($0) }) {
            statusBadgeView.backgroundColor = UIColor(red: 0.3, green: 0.65, blue: 0.35, alpha: 1)
        } else {
            statusBadgeView.backgroundColor = .enabledMainButtonBorderColor
        }
    }

    private func loadCarImage(autoId: Int?) {
        carImageView.image = .carPlaceholder
        guard let autoId else { return }
        let auto = FilterService.shared.allAutos.first { $0.itemID == autoId }
        guard let urlString = auto?.files.first(where: { $0.url != nil && $0.folder == .folderImageValue })?.url,
              let url = URL(string: urlString) else { return }
        let options = ImageLoadingOptions(placeholder: .carPlaceholder, transition: .fadeIn(duration: 0.3))
        NukeExtensions.loadImage(with: url, options: options, into: carImageView)
    }

    private func performLayout() {
        containerView.pin.all()

        let badgeWidth: CGFloat = 44
        let imageWidth: CGFloat = 120

        carImageView.pin
            .left()
            .top()
            .bottom()
            .width(imageWidth)

        statusBadgeView.pin
            .right()
            .top()
            .bottom()
            .width(badgeWidth)

        statusLabel.pin
            .center()
            .width(containerView.bounds.height - 16)
            .height(badgeWidth)

        let contentLeft = imageWidth + 12
        let contentRight = badgeWidth + 12
        let contentWidth = containerView.bounds.width - contentLeft - contentRight

        carNameLabel.pin
            .top(14)
            .left(contentLeft)
            .width(contentWidth)
            .sizeToFit(.width)

        dateFromLabel.pin
            .below(of: carNameLabel)
            .marginTop(8)
            .left(contentLeft)
            .width(contentWidth)
            .sizeToFit(.width)

        dateToLabel.pin
            .below(of: dateFromLabel)
            .marginTop(4)
            .left(contentLeft)
            .width(contentWidth)
            .sizeToFit(.width)
    }
}
