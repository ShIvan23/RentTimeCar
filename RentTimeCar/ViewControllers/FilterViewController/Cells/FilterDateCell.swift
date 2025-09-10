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
    
    private let label = Label(
        text: "Даты бронирования",
        numberOfLines: 1,
        fontSize: 14,
        textAlignment: .left
    )
    
    private let containerView = UIView()
    private let containerLabel = Label(
        text: .defaultContainerLabelText,
        numberOfLines: 1,
        fontSize: 14,
        textAlignment: .left
    )
    private let containerImageView = UIImageView()
    
    // MARK: - Private Properties
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter
    }()
    
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
        if selectedDates.isEmpty {
            containerLabel.text = .defaultContainerLabelText
        } else {
            guard let firstDate = selectedDates.first,
                  let lastDate = selectedDates.last else { return }
            let firstDateString = dateFormatter.string(from: firstDate)
            let lastDateString = dateFormatter.string(from: lastDate)
            containerLabel.text = "C \(firstDateString) по \(lastDateString)"
        }
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        contentView.addSubviews([label, containerView])
        containerView.layer.cornerRadius = 14
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        containerView.layer.borderWidth = 2
        containerView.addSubviews([containerLabel, containerImageView])
        containerImageView.image = .calendar
    }
    
    private func performLayout() {
        label.pin
            .topLeft()
            .sizeToFit()
        
        containerView.pin
            .below(of: label)
            .horizontally()
            .marginTop(8)
            .height(50)
        
        containerImageView.pin
            .right()
            .marginRight(16)
            .size(CGSize(square: 16))
            .vCenter()
        
        containerLabel.pin
            .left()
            .vCenter()
            .right(to: containerImageView.edge.left)
            .marginLeft(16)
            .sizeToFit(.width)
    }
}

private extension String {
    static let defaultContainerLabelText = "Любые даты"
}
