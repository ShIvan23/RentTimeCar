//
//  SideMenuContentTableViewCell.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 01.08.2025.
//

import PinLayout
import UIKit

final class SideMenuContentTableViewCell: UITableViewCell {
    // MARK: - UI
    
    private let image = UIImageView()
    private let textsContainer = TextsContainer()
    private let arrowImageView = UIImageView()
    private let containerView = UIView()
    private var cellType: SideMenuCellType = .small
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
    
    func configure(with model: SideMenuModel) {
        image.isHidden = model.image == nil
        cellType = model.cellType
        if let image = model.image {
            switch model.cellType {
            case .small:
                self.image.image = image.withRenderingMode(.alwaysTemplate)
                self.image.tintColor = .whiteTextColor
            case .big:
                self.image.image = image.withRenderingMode(.alwaysOriginal)
                self.image.tintColor = nil
            }
        }
        textsContainer.configure(title: model.title,
                                 subtitle: model.subtitle)
        arrowImageView.isHidden = !model.hasArrow
        containerView.backgroundColor = model.backgroundColor
        setNeedsLayout()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        contentView.addSubview(containerView)
        containerView.addSubviews([image, textsContainer, arrowImageView])
        containerView.layer.cornerRadius = 6
        arrowImageView.image = .arrow.withRenderingMode(.alwaysTemplate)
        arrowImageView.tintColor = .whiteTextColor
        image.contentMode = .scaleAspectFit
        contentView.backgroundColor = .mainBackground
    }
    
    private func performLayout() {
        containerView.pin
            .all()
            .marginHorizontal(20)
            .marginVertical(10)
        
        if !image.isHidden {
            switch cellType {
            case .small:
                image.pin
                    .left()
                    .size(CGSize(square: 32))
                    .marginLeft(12)
                    .vCenter()
            case .big:
                image.pin
                    .topLeft()
                    .size(CGSize(width: containerView.bounds.height * 1.2,
                                 height: containerView.bounds.height))
            }
        }
        
        arrowImageView.pin
            .right()
            .marginRight(12)
            .size(CGSize(square: 18))
            .vCenter()
        
        textsContainer.pin
            .after(of: visible([image]))
            .right(to: arrowImageView.edge.left)
            .marginHorizontal(14)
            .sizeToFit(.width)
            .vCenter()
    }
}
