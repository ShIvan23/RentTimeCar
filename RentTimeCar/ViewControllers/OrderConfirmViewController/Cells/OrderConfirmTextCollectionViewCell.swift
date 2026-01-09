//
//  OrderConfirmTextCollectionViewCell.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 08.01.2026.
//

import UIKit

final class OrderConfirmTextCollectionViewCell: UICollectionViewCell {
    // MARK: - UI

    private let title = Label(
        fontSize: 12,
        textColor: .secondaryTextColor,
        textAlignment: .left
    )
    private let subtitle = Label(
        textAlignment: .left
    )

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

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let currentSize = CGSize(
            width: size.width - .horizontalMargin * 2,
            height: size.height
        )
        let titleSize = title.sizeThatFits(currentSize)
        let subtitleSize = subtitle.sizeThatFits(currentSize)
        return CGSize(
            width: size.width,
            height: titleSize.height + .subtitleTopMargin * 2 + subtitleSize.height
        )
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        performLayout()
    }

    // MARK: - Internal Methods

    func configure(model: OrderConfirmModel.OrderConfirmText) {
        title.text = model.title
        subtitle.text = model.subtitle
    }

    // MARK: - Private Methods

    private func setupView() {
        contentView.addSubviews([title, subtitle])
        contentView.backgroundColor = .secondaryBackground
        contentView.layer.cornerRadius = 16
    }

    private func performLayout() {
        title.pin
            .top()
            .horizontally()
            .marginHorizontal(20)
            .marginTop(4)
            .sizeToFit(.width)

        subtitle.pin
            .below(of: title)
            .horizontally()
            .marginTop(.subtitleTopMargin / 2)
            .marginHorizontal(20)
            .sizeToFit(.width)
    }
}

private extension CGFloat {
    static let subtitleTopMargin: CGFloat = 10
    static let horizontalMargin: CGFloat = 20
}
