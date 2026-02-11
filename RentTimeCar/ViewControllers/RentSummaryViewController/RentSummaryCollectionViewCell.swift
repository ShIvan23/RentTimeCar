//
//  RentSummaryCollectionViewCell.swift
//  RentTimeCar
//
//  Created by Андрей Пермяков on 09.02.2026.
//

import UIKit
import PinLayout

struct RentItem {
    let title: String
    let amount: Int
    let icon: UIImage?
}

final class RentSummaryCollectionViewCell: UICollectionViewCell {

    static let reuseId = "RentSummaryCollectionViewCell"

    private lazy var iconImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.isHidden = true
        return image
    }()

    private let titleLabel = Label(
        text: "",
        numberOfLines: 1,
        fontSize: 16,
        textColor: .secondaryTextColor,
        textAlignment: .left
    )

    private let valueLabel = Label(
        text: "",
        numberOfLines: 1,
        fontSize: 16,
        textColor: .whiteTextColor,
        textAlignment: .right
    )

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.isHidden = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutCell()
    }
    
    private func setupViews(){
        contentView.addSubviews([iconImage, titleLabel, valueLabel, separatorView])
    }
    
    func setSeparatorVisible(_ visible: Bool) {
        separatorView.isHidden = !visible
    }

    private func layoutCell() {
        let horizontalInset: CGFloat = 16
        let iconSize: CGFloat = 16
        let titleLeftInset: CGFloat = 50
        let separatorInset: CGFloat = 32

        iconImage.pin
            .size(CGSize(width: iconSize, height: iconSize))
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

        separatorView.pin
            .top()
            .left(separatorInset)
            .right(separatorInset)
            .height(1)
    }

    func configure(with item: RentItem) {
        titleLabel.text = item.title
        valueLabel.text = item.amount > 0 ? "\(item.amount) ₽" : ""

        iconImage.image = item.icon?.withRenderingMode(.alwaysTemplate)
        iconImage.tintColor = item.icon == nil ? nil : .white
        iconImage.isHidden = item.icon == nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImage.image = nil
        iconImage.isHidden = true
        titleLabel.text = nil
        valueLabel.text = nil
    }
}
