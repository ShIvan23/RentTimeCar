//
//  EmptyCell.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 13.08.2025.
//

import UIKit

final class EmptyCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.backgroundColor = .clear
    }
}
