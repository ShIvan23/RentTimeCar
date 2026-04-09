//
//  InsuranceView.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 16.10.2025.
//

import PinLayout
import UIKit

// Вьюшка, которая используется на деталке под фото с информацией о страховке
final class InsuranceView: UIView {
    // MARK: - UI
    
    private let label = Label(
        text: "Страховка ОСАГО и КАСКО уже включены в стоимость",
        fontSize: 14,
        textAlignment: .left
    )
    
    // MARK: Init
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        let textSize = label.sizeThatFits(size)
        return CGSize(width: textSize.width,
                      height: size.height)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        performLayout()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        addSubview(label)
        backgroundColor = .secondaryBackground
        layer.cornerRadius = 22
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    private func performLayout() {
        label.pin
            .top()
            .horizontally()
            .marginTop(8)
            .marginHorizontal(16)
            .sizeToFit(.width)
    }
}
