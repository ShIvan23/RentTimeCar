//
//  FilterDateCell.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 14.08.2025.
//

import PinLayout
import UIKit

final class FilterDateCell: UICollectionViewCell {
    // MARK: - UI
    
    private let selectDateView = SelectDateView()
    
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
    
    func configure(selectedDates: [Date]) {
        selectDateView.configure(selectedDates: selectedDates)
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        contentView.addSubview(selectDateView)
    }
    
    private func performLayout() {
        selectDateView.pin.all()
    }
}
