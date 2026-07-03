//
//  UIFont+Extension.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 29.07.2025.
//

import UIKit

extension UIFont {
    static func openSans(fontSize: CGFloat = 16, weight: Weight = .regular) -> UIFont? {
        let name: String
        switch weight {
        case .bold, .heavy, .black:       name = "OpenSans-Bold"
        case .semibold:                   name = "OpenSans-SemiBold"
        case .medium:                     name = "OpenSans-Medium"
        case .light, .ultraLight, .thin:  name = "OpenSans-Light"
        default:                          name = "OpenSans-Regular"
        }
        return UIFont(name: name, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: weight)
    }
    static let roboto = UIFont(name: "Roboto", size: 16)
}
