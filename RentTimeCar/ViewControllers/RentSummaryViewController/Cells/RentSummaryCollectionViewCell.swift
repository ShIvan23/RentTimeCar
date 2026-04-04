//
//  RentSummaryCollectionViewCell.swift
//  RentTimeCar
//
//  Created by Андрей Пермяков on 09.02.2026.
//

import UIKit
import PinLayout

// MARK: - Models

enum RentSummaryCellModel {
    case item(RentItem)
    case separator
}

struct RentItem {
    let title: String
    let amount: Int
    let icon: UIImage?
    var amountText: String? = nil
}

// MARK: - Cell

final class RentSummaryCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Private Properties
    private lazy var iconImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.tintColor = .white
        image.isHidden = true
        return image
    }()

    private let titleLabel = Label(
        numberOfLines: 1,
        textColor: .secondaryTextColor,
        textAlignment: .left
    )

    private let valueLabel = Label(
        numberOfLines: 1,
        textAlignment: .right
    )

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override Methods
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutCell()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImage.image = nil
        iconImage.isHidden = true
        titleLabel.text = nil
        valueLabel.text = nil
    }

    // MARK: - Internal Methods
    func configure(with item: RentItem) {
        titleLabel.text = item.title
        if let amountText = item.amountText {
            valueLabel.text = amountText
        } else {
            valueLabel.text = item.amount > 0 ? "\(item.amount) ₽" : ""
        }
        iconImage.image = item.icon?.withRenderingMode(.alwaysTemplate)
        iconImage.isHidden = item.icon == nil
    }

    // MARK: - Private Methods
    private func setupViews(){
        contentView.addSubviews([iconImage, titleLabel, valueLabel])
    }

    private func layoutCell() {
        let horizontalInset: CGFloat = 16
        let iconSize = CGSize(square: 16)
        let titleLeftInset: CGFloat = 50

        iconImage.pin
            .size(iconSize)
            .left(horizontalInset)
            .vCenter()

        titleLabel.pin
            .left(titleLeftInset)
            .vCenter()
            .sizeToFit()

        valueLabel.pin
            .right(horizontalInset)
            .vCenter()
            .sizeToFit()
    }
}
