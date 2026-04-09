//
//  FilterValueCell.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 15.08.2025.
//

import PinLayout
import UIKit

protocol FilterValueCellDelegate: AnyObject {
    func filterValuesChanged(newModel: FilterValueModel, cellType: FilterValueCell.CellType)
    func filterValuesDidEndDragging()
}

final class FilterValueCell: UICollectionViewCell {
    enum CellType {
        case price
        case motorPower
    }
    
    // MARK: - Internal Properties
    
    weak var delegate: FilterValueCellDelegate?
    
    // MARK: - UI
    
    private let minValueView = FilterValueContainerView(type: .from)
    private let maxValueView = FilterValueContainerView(type: .to)
    private let doubleSliderView = DoubledSlider()
    
    // MARK: - Private Properties
    
    private var cellType: CellType = .price
    private var model: FilterValueModel = FilterValueModel(
        minValue: .zero,
        maxValue: .zero,
        minValueNow: .zero,
        maxValueNow: .zero
    )
    
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
    
    func configure(with model: FilterValueModel, cellType: CellType) {
        self.model = model
        minValueView.configure(value: model.minValueNow)
        maxValueView.configure(value: model.maxValueNow)
        doubleSliderView.configure(with: model)
        self.cellType = cellType
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        addSubviews([minValueView, maxValueView, doubleSliderView])
        doubleSliderView.delegate = self
        doubleSliderView.endDraggingDelegate = self
        minValueView.delegate = self
        maxValueView.delegate = self
    }
    
    private func performLayout() {
        let availableWidth = (bounds.width - .valuesBetweenMargin) / 2
        minValueView.pin
            .topLeft()
            .size(CGSize(width: availableWidth, height: .filterValueCellMinMaxViewHeight))
        
        maxValueView.pin
            .after(of: minValueView)
            .marginLeft(.valuesBetweenMargin)
            .size(CGSize(width: availableWidth, height: .filterValueCellMinMaxViewHeight))
        
        doubleSliderView.pin
            .below(of: minValueView)
            .horizontally()
            .marginTop(.filterValueCellDoubleSliderTopMargin)
            .height(.filterValueCellDoubleSliderHeight)
    }
    
    private func callDelegate() {
        delegate?.filterValuesChanged(newModel: model, cellType: cellType)
    }
}

// MARK: - DoubledSliderDelegate

extension FilterValueCell: DoubledSliderDelegate {
    func minValueDidChange(_ value: Int) {
        minValueView.configure(value: value)
        model.minValueNow = value
        callDelegate()
    }
    
    func maxValueDidChange(_ value: Int) {
        maxValueView.configure(value: value)
        model.maxValueNow = value
        callDelegate()
    }
}

// MARK: - DoubledSliderEndDraggingDelegate

extension FilterValueCell: DoubledSliderEndDraggingDelegate {
    func didEndDragging() {
        delegate?.filterValuesDidEndDragging()
    }
}

// MARK: - FilterValueContainerViewDelegate

extension FilterValueCell: FilterValueContainerViewDelegate {
    func didEnterNewValue(_ value: Int, type: FilterValueContainerView.FilterValueType) {
        switch type {
        case .from:
            doubleSliderView.setMinValue(value)
            model.minValueNow = value
        case .to:
            doubleSliderView.setMaxValue(value)
            model.maxValueNow = value
        }
        callDelegate()
    }
}

// MARK: - CGFloat

extension CGFloat {
    static let filterValueCellMinMaxViewHeight: CGFloat = 50
    static let filterValueCellDoubleSliderTopMargin: CGFloat = 10
    static let filterValueCellDoubleSliderHeight: CGFloat = 60
    static let valuesBetweenMargin: CGFloat = 8
}
