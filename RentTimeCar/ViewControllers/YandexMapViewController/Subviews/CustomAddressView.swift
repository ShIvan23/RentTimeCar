//
//  CustomAddressView.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 24.11.2025.
//

import PinLayout
import UIKit

final class CustomAddressView: UIView {
    // MARK: - UI
    
    private let label = Label(
        text: "Адрес доставки",
        numberOfLines: 1,
        fontSize: 13,
        textAlignment: .center
    )
    private let crossButton = IconButton(image: .redCross)
    private let containerView = UIView()
    private let containerLabel = Label(
        text: "Введите адрес",
        numberOfLines: 1,
        fontSize: 14,
        textAlignment: .left
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
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        autoSizeThatFits(size, layoutClosure: performLayout)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        performLayout()
    }
    
    // MARK: - Internal Methods
    
    func configure(with address: String) {
        containerLabel.text = address
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        addSubviews([containerView, label])
        containerView.addSubviews([containerLabel, crossButton])
        containerView.layer.cornerRadius = 14
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        containerView.layer.borderWidth = 2
        label.backgroundColor = .mainBackground
    }
    
    private func performLayout() {
        containerView.pin
            .top()
            .horizontally()
            .marginTop(10)
            .height(50)
        
        let labelContentSize = label.sizeThatFits(bounds.size)
        
        label.pin
            .topLeft()
            .marginLeft(30)
            .size(CGSize(
                width: labelContentSize.width + 12,
                height: labelContentSize.height))
        
        crossButton.pin
            .right()
            .vCenter()
            .marginRight(12)
            .size(CGSize(square: 24))
        
        containerLabel.pin
            .left()
            .right(to: crossButton.edge.left)
            .marginHorizontal(10)
            .vCenter()
            .sizeToFit(.width)
    }
}
