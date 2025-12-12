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
    private let label = Label(
        numberOfLines: 1,
        fontSize: 14
    )
    private let isSelectedImageView = UIImageView()
    private let removeFiltersButton = UIButton()
    
    // MARK: - Private Properties
    
    private var filterType: FilterType?
    
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
        filterType = model.type
        imageView.image = model.image.withRenderingMode(.alwaysTemplate)
        label.isHidden = model.text == nil
        label.text = model.text
        isSelectedImageView.isHidden = !model.isSelected
        removeFiltersButton.isHidden = !model.isSelected
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        contentView.addSubviews([imageView, label, isSelectedImageView, removeFiltersButton])
        isSelectedImageView.isHidden = true
        removeFiltersButton.isHidden = true
        contentView.backgroundColor = .secondaryBackground
        contentView.layer.cornerRadius = 10
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .whiteTextColor
        isSelectedImageView.image = .circleYellow
        isSelectedImageView.contentMode = .scaleAspectFit
        removeFiltersButton.setImage(.redCross, for: .normal)
        removeFiltersButton.addTarget(self, action: #selector(removeFiltersButtonAction), for: .touchUpInside)
    }
    
    @objc
    private func removeFiltersButtonAction() {
        guard let filterType else { return }
        switch filterType {
        case .filter:
            FilterService.shared.resetAllFilters()
        case .date:
            FilterService.shared.setSelectedDates([])
        case .sort:
            ()
        case .autoType:
            ()
        case .delete:
            ()
        }
    }
    
    private func performLayout() {
        imageView.pin
            .left()
            .vCenter()
            .marginLeft(.filterCellMargin)
            .size(.filterCellIconSize)

        let textSize = label.sizeThatFits(bounds.size)
        label.pin
            .after(of: imageView, aligned: .center)
            .marginLeft(.filterCellMargin)
            .size(textSize)

        if !isSelectedImageView.isHidden {
            isSelectedImageView.pin
                .after(of: label, aligned: .center)
                .marginLeft(.filterCellMargin)
                .size(.filterCellIconSize)
        }
        
        if !removeFiltersButton.isHidden {
            removeFiltersButton.pin
                .after(of: isSelectedImageView, aligned: .center)
                .marginLeft(.filterCellMargin)
                .size(.filterCellIconSize)
        }
    }
}

extension CGFloat {
    static let filterCellMargin: CGFloat = 6
}

extension CGSize {
    static let filterCellIconSize = CGSize(square: 20)
}
