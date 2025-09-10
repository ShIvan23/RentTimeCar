//
//  FilterClassCell.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 08.09.2025.
//

import PinLayout
import UIKit

final class FilterClassCell: UICollectionViewCell {
    // MARK: - UI
    
    private let label = Label(textAlignment: .left)
    
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
    
    func configure(with model: FilterClassAuto) {
        label.text = model.name
        isSelectedCell = model.isSelected
        updateSelectionCell() 
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        contentView.addSubview(label)
        contentView.backgroundColor = .secondaryBackground
        contentView.layer.cornerRadius = 8
    }
    
    private func updateSelectionCell() {
        contentView.backgroundColor = isSelectedCell ? .secondaryTextColor : .secondaryBackground
    }
    
    private func performLayout() {
        label.pin
            .all()
            .marginTop(.filterClassCellVerticalMargin)
            .marginLeft(.filterClassCellHorizontalMargin)
            .sizeToFit(.width)
    }
}


extension CGFloat {
    static let filterClassCellHorizontalMargin: CGFloat = 8
    static let filterClassCellVerticalMargin: CGFloat = 4
}
