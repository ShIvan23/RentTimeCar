//
//  InfoViewContentView.swift
//  RentTimeCar
//
//  Created by Андрей Пермяков on 14.02.2026.
//

import UIKit
import PinLayout

final class InfoViewContentView: UIView {
    
    // MARK: - Private Properties
    private let iconImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(resource: .info).withRenderingMode(.alwaysTemplate)
        image.tintColor = .whiteTextColor
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private let infoLabel = Label(fontSize: 12)
    
    private let arrowView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondaryBackground
        view.transform = CGAffineTransform(rotationAngle: .pi / 4)
        return view
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override Methods
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        autoSizeThatFits(size, layoutClosure: layout)
    }
    
    // MARK: - Internal Methods
    func configure(text: String) {
        infoLabel.text = text
    }
    
    // MARK: - Private Methods
    private func setupView() {
        backgroundColor = .secondaryBackground
        layer.cornerRadius = 12
        addSubviews([iconImage, infoLabel, arrowView])
    }
    
    private func layout() {
        iconImage.pin
            .top(8)
            .hCenter()
            .size(16)
        
        infoLabel.pin
            .below(of: iconImage)
            .horizontally(8)
            .marginBottom(8)
            .sizeToFit(.width)
        
        arrowView.pin
            .size(10)
            .hCenter()
            .bottom(-5)
    }
}
