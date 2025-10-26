//
//  BrandAutoCell.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 14.08.2025.
//

import Nuke
import NukeExtensions
import PinLayout
import UIKit

final class BrandAutoCell: UICollectionViewCell {
    // MARK: - UI
    
    private let imageView = UIImageView()
    
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
        
        guard let urlString = model.image,
              let url = URL(string: urlString) else {
            imageView.image = nil
            return
        }
        NukeExtensions.loadImage(with: url, into: imageView)
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        contentView.addSubviews([imageView, label])
        contentView.backgroundColor = .mainBackground
        contentView.layer.cornerRadius = 14
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.borderWidth = 2
        
        imageView.contentMode = .scaleAspectFit
        
    }
    
    private func updateSelectionCell() {
        contentView.backgroundColor = isSelectedCell ? .secondaryTextColor : .mainBackground
    }
    
    private func performLayout() {
        imageView.pin
            .top()
            .hCenter()
            .size(CGSize(square: 60))
        
        label.pin
            .below(of: imageView)
            .horizontally()
            .sizeToFit(.width)
    }
}
