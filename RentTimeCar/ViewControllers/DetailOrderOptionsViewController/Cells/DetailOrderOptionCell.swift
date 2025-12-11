//
//  DetailOrderOptionCell.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 10.12.2025.
//

import UIKit

final class DetailOrderOptionCell: UICollectionViewCell {
    // MARK: - UI

    private let imageView = UIImageView()
    private let titleSubtitleView = TitleSubtitleView()
    private let switcher = UISwitch()

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

    // MARK: - Internal Methods

    func configure(with model: DetailOrderOptionModel, delegate: TitleSubtitleViewDelegate) {
        titleSubtitleView.configure(
            title: model.title,
            subtitle: model.subtitle,
            cellType: model.type,
            delegate: delegate
        )
        imageView.image = model.image.withRenderingMode(.alwaysTemplate)
    }

    // MARK: - Private Methods

    private func setupView() {
        contentView.addSubviews([imageView, titleSubtitleView, switcher])
        contentView.backgroundColor = .secondaryBackground
        contentView.layer.cornerRadius = 16
        imageView.tintColor = .whiteTextColor
        imageView.backgroundColor = .secondaryBackground
        switcher.onTintColor = .red
    }

    private func performLayout() {
        imageView.pin
            .left()
            .vCenter()
            .marginLeft(10)
            .size(CGSize(square: 24))

        switcher.pin
            .right()
            .vCenter()
            .marginRight(10)
            .sizeToFit()

        titleSubtitleView.pin
            .horizontallyBetween(imageView, and: switcher)
            .vCenter()
            .marginHorizontal(12)
            .sizeToFit(.width)
    }
}
