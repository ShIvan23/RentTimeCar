//
//  SeparatorCell.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 14.08.2025.
//

import PinLayout
import UIKit

final class SeparatorCell: UICollectionViewCell {
    // MARK: - UI
    
    private let separatorView = UIView()
    
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
    
    // MARK: - Private Methods
    
    private func setupView() {
        contentView.addSubview(separatorView)
        separatorView.backgroundColor = .lightGray
    }
    
    private func performLayout() {
        separatorView.pin
            .all()
            .marginHorizontal(12)
    }
}
