//
//  FilterCell.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 13.08.2025.
//

import PinLayout
import UIKit

final class FilterCell: UICollectionViewCell {
    // MARK: - UI
    
    private let imageView = UIImageView()
    private let label = Label(fontSize: 14)
    
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
    
    // MARK: - Internal Methods
    
    func configure(with model: FilterModel) {
        imageView.image = model.image.withRenderingMode(.alwaysTemplate)
        label.isHidden = model.text == nil
        label.text = model.text
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        contentView.addSubviews([imageView, label])
        contentView.backgroundColor = .secondaryBackground
        contentView.layer.cornerRadius = 10
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .whiteTextColor
    }
    
    private func performLayout() {
        let imageWidth = contentView.bounds.height - .filterCellMargin * 2
        imageView.pin
            .left()
//            .vertically()
//            .marginVertical(.filterCellMargin)
            .marginLeft(.filterCellMargin)
            .size(CGSize(square: 20))
            .vCenter()
//            .width(imageWidth)
//            .size(CGSize(square: imageHeight))
        
        label.pin
            .after(of: imageView, aligned: .center)
            .right()
            .marginHorizontal(.filterCellMargin)
            .sizeToFit(.width)
    }
}

extension CGFloat {
    static let filterCellMargin: CGFloat = 6
}
