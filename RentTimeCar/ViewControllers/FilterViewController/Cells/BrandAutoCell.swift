//
//  BrandAutoCell.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 14.08.2025.
//

import PinLayout
import UIKit

final class BrandAutoCell: UICollectionViewCell {
    // MARK: - UI
    
    private let label = Label(
        numberOfLines: 1,
        fontSize: 14
    )
    
    // MARK: - Private Properties
    
    private var isSelectedCell = false
    
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
    
    func configure(with model: FilterBrandAuto) {
        isSelectedCell = model.isSelected
        label.text = model.name
        updateSelectionCell()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        contentView.addSubview(label)
        contentView.backgroundColor = .mainBackground
        contentView.layer.cornerRadius = 14
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.borderWidth = 2
    }
    
    private func updateSelectionCell() {
        contentView.backgroundColor = isSelectedCell ? .secondaryTextColor : .mainBackground
    }
    
    private func performLayout() {
        label.pin.all()
    }
}
