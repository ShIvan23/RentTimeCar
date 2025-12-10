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
    private let arrowImageView = UIImageView()
    private let containerView = UIView()
    private let containerLabel = Label(
        text: .defaultText,
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
    
    func resetText() {
        containerLabel.text = .defaultText
    }

    func getAddress() -> String? {
        guard let address = containerLabel.text,
              address != .defaultText else { return nil }
        return address
    }

    // MARK: - Private Methods
    
    private func setupView() {
        addSubviews([containerView, label])
        containerView.addSubviews([containerLabel, arrowImageView])
        containerView.layer.cornerRadius = 14
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        containerView.layer.borderWidth = 2
        label.backgroundColor = .mainBackground
        arrowImageView.image = .arrow.withRenderingMode(.alwaysTemplate)
        arrowImageView.tintColor = .whiteTextColor
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
        
        arrowImageView.pin
            .right()
            .vCenter()
            .marginRight(12)
            .size(CGSize(square: 16))
        
        containerLabel.pin
            .left()
            .right(to: arrowImageView.edge.left)
            .marginHorizontal(10)
            .vCenter()
            .sizeToFit(.width)
    }
}

private extension String {
    static let defaultText = "Введите адрес"
}
