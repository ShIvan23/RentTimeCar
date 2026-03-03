//
//  RegistrationImageCell.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 28.02.2026.
//

import UIKit

final class RegistrationImageCell: UICollectionViewCell {

    // MARK: - UI

    private let imageView = UIImageView()

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

    func configure(with image: UIImage) {
        imageView.image = image
    }

    // MARK: - Private Methods

    private func setupView() {
        contentView.addSubview(imageView)
        contentView.backgroundColor = .secondaryBackground
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
    }

    private func performLayout() {
        imageView.pin.all()
    }
}
