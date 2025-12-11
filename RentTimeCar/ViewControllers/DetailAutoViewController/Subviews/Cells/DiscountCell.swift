//
//  DiscountCell.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 16.10.2025.
//

import PinLayout
import UIKit

final class DiscountCell: UICollectionViewCell {
    // MARK: - UI
    
    private let daysCountLabel = Label(textAlignment: .left)
    private let priceLabel = Label(textAlignment: .left)
    
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
    
    // MARK: - Override
    
    override func prepareForReuse() {
        super.prepareForReuse()
        daysCountLabel.text = ""
        priceLabel.text = ""
    }
    
    // MARK: - Internal Methods
    
    func configure(daysCount: Int, priceByDay: Int) {
        daysCountLabel.text = "\(daysCount) сутки"
        priceLabel.text = "\(priceByDay * daysCount) ₽/сутки"
    }

    // MARK: - Private Methods

    private func setupView() {
        contentView.addSubviews([daysCountLabel, priceLabel])
        contentView.backgroundColor = .black
        contentView.layer.cornerRadius = 16
    }
    
    private func performLayout() {
        daysCountLabel.pin
            .topLeft()
            .marginTop(10)
            .marginLeft(12)
            .sizeToFit()
        
        priceLabel.pin
            .below(of: daysCountLabel)
            .left(to: daysCountLabel.edge.left)
            .marginTop(12)
            .sizeToFit()
    }
}
