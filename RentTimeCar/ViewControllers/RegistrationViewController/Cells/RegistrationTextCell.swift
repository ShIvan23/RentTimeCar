//
//  RegistrationTextCell.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 27.02.2026.
//

import UIKit

final class RegistrationTextCell: UICollectionViewCell {
    enum Constants {
        static let margin: CGFloat = 16
    }

    // MARK: - UI

    private let textLabel = Label(textAlignment: .left)

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

    func configure(with text: String) {
        textLabel.text = text
        setNeedsLayout()
    }

    // MARK: - Private Methods

    private func setupView() {
        contentView.addSubview(textLabel)
        contentView.backgroundColor = .secondaryBackground
        contentView.layer.cornerRadius = 12
    }

    private func performLayout() {
        textLabel.pin.all(Constants.margin)
    }
}
