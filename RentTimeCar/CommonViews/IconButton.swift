//
//  IconButton.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 30.07.2025.
//

import UIKit

final class IconButton: UIButton {
    var action: (() -> Void)?
    
    init(image: UIImage?) {
        super.init(frame: .zero)
        setupButton(image: image)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton(image: UIImage?) {
        let renderedImage = image?.withRenderingMode(.alwaysTemplate)
        setImage(renderedImage, for: .normal)
        tintColor = .whiteTextColor
        addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }
    
    @objc
    private func buttonAction() {
        action?()
    }
}
