//
//  OrderConfirmImageCollectionViewCell.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 08.01.2026.
//

import NukeExtensions
import UIKit

final class OrderConfirmImageCollectionViewCell: UICollectionViewCell {
    // MARK: - UI

    private let imageView = UIImageView()

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

    override public func layoutSubviews() {
        super.layoutSubviews()
        performLayout()
    }

    // MARK: - Internal Methods

    func configure(with model: OrderConfirmModel.OrderConfirmImage) {
        guard let url = URL(string: model.imageUrl) else { return }
        NukeExtensions.loadImage(with: url, into: imageView)
    }

    // MARK: - Private Methods

    private func setupView() {
        contentView.addSubview(imageView)
        contentView.backgroundColor = .clear
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
    }

    private func performLayout() {
        imageView.pin
            .all()
    }
}
