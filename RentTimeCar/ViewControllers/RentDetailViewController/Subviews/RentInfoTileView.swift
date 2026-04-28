//
//  RentInfoTileView.swift
//  RentTimeCar
//

import PinLayout
import UIKit

final class RentInfoTileView: UIView {

    // MARK: - UI

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryTextColor
        l.numberOfLines = 2
        return l
    }()

    private let valueLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .medium)
        l.textColor = .whiteTextColor
        l.numberOfLines = 2
        return l
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondaryBackground
        layer.cornerRadius = 10
        addSubviews([titleLabel, valueLabel])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.pin.top(10).horizontally(12).sizeToFit(.width)
        valueLabel.pin.below(of: titleLabel).marginTop(4).horizontally(12).sizeToFit(.width)
    }

    // MARK: - Internal Methods

    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
    }
}
