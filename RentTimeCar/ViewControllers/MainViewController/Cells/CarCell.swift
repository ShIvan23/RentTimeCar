//
//  CarCell.swift
//  RentTimeCar
//
//  Created by Ekaterina Volobueva on 31.07.2025.
//

import Nuke
import NukeExtensions
import NukeUI
import PinLayout
import UIKit

final class CarCell: UICollectionViewCell {
    // MARK: - UI

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let titleLabel = Label(numberOfLines: 1, textAlignment: .left)
    private let priceLabel = Label(numberOfLines: 1, textAlignment: .left)

    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.black.withAlphaComponent(0.8).cgColor,
            UIColor.clear.cgColor
        ]
        layer.locations = [0, 1]
        return layer
    }()

    private let statusBadgeView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        v.layer.cornerRadius = 10
        v.isHidden = true
        return v
    }()

    private let statusDot: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 4
        return v
    }()

    private let statusLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = .white
        return l
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        autoSizeThatFits(size, layoutClosure: performLayout)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        performLayout()
    }

    // MARK: - Override

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = ""
        priceLabel.text = ""
        statusBadgeView.isHidden = true
    }

    // MARK: - Internal Methods

    func configure(model: Auto, status: AutoAvailabilityStatus? = nil) {
        titleLabel.text = model.title
        priceLabel.text = "\(model.defaultPriceWithDiscountSt) ₽/сутки"

        if let status {
            statusLabel.text = status.badgeText
            statusDot.backgroundColor = status.dotColor
            statusBadgeView.isHidden = false
        } else {
            statusBadgeView.isHidden = true
        }

        setNeedsLayout()

        guard let urlString = model.files.first(where: { $0.url != nil && $0.folder == .folderImageValue })?.url,
              let url = URL(string: urlString)
        else { return }

        let options = ImageLoadingOptions(placeholder: .carPlaceholder, transition: .fadeIn(duration: 0.3))
        NukeExtensions.loadImage(with: url, options: options, into: imageView)
    }
}

// MARK: - Private Methods

private extension CarCell {
    func setupView() {
        contentView.backgroundColor = .mainBackground
        contentView.addSubview(imageView)
        imageView.layer.addSublayer(gradientLayer)
        imageView.addSubviews([titleLabel, priceLabel, statusBadgeView])
        statusBadgeView.addSubviews([statusDot, statusLabel])
    }

    func performLayout() {
        imageView.pin.all()

        gradientLayer.pin
            .top()
            .horizontally()
            .height(bounds.height * 0.3)

        titleLabel.pin
            .top(4)
            .horizontally(10)
            .sizeToFit(.width)

        priceLabel.pin
            .below(of: titleLabel, aligned: .left)
            .marginTop(4)
            .horizontally(10)
            .sizeToFit(.width)

        guard !statusBadgeView.isHidden else { return }

        let badgeH: CGFloat = 22
        let dotSize: CGFloat = 8
        let hPad: CGFloat = 10
        let gap: CGFloat = 5

        let labelSize = statusLabel.sizeThatFits(CGSize(width: bounds.width, height: badgeH))
        let badgeW = hPad + dotSize + gap + labelSize.width + hPad

        statusBadgeView.pin
            .bottom(10)
            .right(10)
            .width(badgeW)
            .height(badgeH)

        let dotY = (badgeH - dotSize) / 2
        statusDot.pin.left(hPad).top(dotY).size(CGSize(width: dotSize, height: dotSize))
        statusLabel.pin
            .after(of: statusDot).marginLeft(gap)
            .vCenter()
            .width(labelSize.width)
            .height(labelSize.height)
    }
}
