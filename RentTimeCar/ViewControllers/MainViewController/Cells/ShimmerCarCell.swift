//
//  ShimmerCarCell.swift
//  RentTimeCar
//

import UIKit

final class ShimmerCarCell: UICollectionViewCell {

    private let shimmerView = ShimmerView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        contentView.addSubview(shimmerView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        shimmerView.frame = contentView.bounds
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            shimmerView.startAnimating()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        shimmerView.startAnimating()
    }
}
