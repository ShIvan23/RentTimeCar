//
//  Label.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 29.07.2025.
//

import UIKit

final class Label: UILabel {
    init(
        text: String = "",
        numberOfLines: Int = 0,
        fontSize: CGFloat = 16,
        textColor: UIColor = .whiteTextColor,
        textAlignment: NSTextAlignment = .center
    ) {
        super.init(frame: .zero)
        setupLabel(with: text,
                   numberOfLines: numberOfLines,
                   fontSize: fontSize,
                   textColor: textColor,
                   textAlignment: textAlignment)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let text else { return .zero }
        let size = (text as NSString).size(withAttributes: [.font: font])
//        print("+++ text = \(text), size = \(size)")
        return size
    }
    
    private func setupLabel(
        with text: String,
        numberOfLines: Int,
        fontSize: CGFloat,
        textColor: UIColor,
        textAlignment: NSTextAlignment
    ) {
        self.text = text
        font = UIFont.openSans(fontSize: fontSize)
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.numberOfLines = numberOfLines
    }
}
