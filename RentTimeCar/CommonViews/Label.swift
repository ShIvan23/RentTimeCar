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
        weight: UIFont.Weight = .regular,
        textColor: UIColor = .whiteTextColor,
        textAlignment: NSTextAlignment = .natural
    ) {
        super.init(frame: .zero)
        setupLabel(with: text,
                   numberOfLines: numberOfLines,
                   fontSize: fontSize,
                   weight: weight,
                   textColor: textColor,
                   textAlignment: textAlignment)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let text, !text.isEmpty else { return .zero }
        let constraintSize = CGSize(width: size.width, height: .greatestFiniteMagnitude)
        let rect = (text as NSString).boundingRect(
            with: constraintSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font as Any],
            context: nil
        )
        return CGSize(width: ceil(rect.width), height: ceil(rect.height))
    }
    
    private func setupLabel(
        with text: String,
        numberOfLines: Int,
        fontSize: CGFloat,
        weight: UIFont.Weight,
        textColor: UIColor,
        textAlignment: NSTextAlignment
    ) {
        self.text = text
        font = UIFont.openSans(fontSize: fontSize, weight: weight)
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.numberOfLines = numberOfLines
    }
}
