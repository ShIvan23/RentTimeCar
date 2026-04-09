//
//  DetailOrderOptionCell.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 10.12.2025.
//

import UIKit

protocol DetailOrderOptionCellDelegate: AnyObject {
    func switcherValueDidChange(_ value: Bool, text: String)
}

final class DetailOrderOptionCell: UICollectionViewCell {
    // MARK: - UI

    private let imageView = UIImageView()
    private let titleSubtitleView = TitleSubtitleView()
    private let switcher = UISwitch()

    // MARK: - Private Properties

    private weak var delegate: DetailOrderOptionCellDelegate?

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

    func configure(
        with model: DetailOrderOptionModel,
        isSelected: Bool,
        titleSubtitleViewDelegate: TitleSubtitleViewDelegate,
        detailOrderOptionCellDelegate: DetailOrderOptionCellDelegate
    ) {
        titleSubtitleView.configure(
            title: model.title,
            subtitle: model.subtitle,
            cellType: model.type,
            delegate: titleSubtitleViewDelegate
        )
        imageView.image = model.image.withRenderingMode(.alwaysTemplate)
        switcher.isOn = isSelected
        delegate = detailOrderOptionCellDelegate
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        switcher.isOn = false
        delegate = nil
    }

    // MARK: - Private Methods

    private func setupView() {
        contentView.addSubviews([imageView, titleSubtitleView, switcher])
        contentView.backgroundColor = .secondaryBackground
        contentView.layer.cornerRadius = 16
        imageView.tintColor = .whiteTextColor
        imageView.backgroundColor = .secondaryBackground
        switcher.onTintColor = .red
        switcher.addTarget(self, action: #selector(switcherValueDidChange), for: .valueChanged)
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

    @objc
    private func switcherValueDidChange(switcher: UISwitch) {
        delegate?.switcherValueDidChange(switcher.isOn, text: titleSubtitleView.getTitle())
    }
}
