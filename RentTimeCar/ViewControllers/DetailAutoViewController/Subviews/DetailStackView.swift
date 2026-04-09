//
//  DetailStackView.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 15.10.2025.
//

import PinLayout
import UIKit

// Вьюшка, которая используется на деталке под фото для stackView
final class DetailStackView: UIView {
    // MARK: - UI
    
    private let imageView = UIImageView()
    private let label = Label(fontSize: 14)
    
    // MARK: Init
    
    init(
        image: UIImage,
        text: String
    ) {
        super.init(frame: .zero)
        setupView(image: image, text: text)
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
    
    private func setupView(image: UIImage, text: String) {
        addSubviews([imageView, label])
        imageView.image = image.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .whiteTextColor
        label.text = text
    }
    
    private func performLayout() {
        imageView.pin
            .top()
            .hCenter()
            .marginTop(8)
            .size(CGSize(square: 18))
        
        label.pin
            .below(of: imageView)
            .hCenter()
            .sizeToFit()
    }
}
