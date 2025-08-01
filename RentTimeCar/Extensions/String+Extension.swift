//
//  String+Extension.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 30.07.2025.
//

import UIKit

extension String {
    func applyPhoneNumberMask() -> String {
        let cleanNumber = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = "(XXX) - XXX - XX - XX"
        var result = ""
        var index = cleanNumber.startIndex
        
        for ch in mask {
            if ch == "X" {
                if index < cleanNumber.endIndex {
                    result.append(cleanNumber[index])
                    index = cleanNumber.index(after: index)
                } else {
                    break
                }
            } else {
                result.append(ch)
            }
        }
        return result
    }
    
    func cancelPhoneNumberMask() -> String {
        self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
}

// For Tagged Label
extension String {
    static func format(strings: [String],
                    inString string: String,
                    font: UIFont,
                    color: UIColor) -> NSAttributedString {
        let attributedString =
            NSMutableAttributedString(string: string,
                                    attributes: [
                                        NSAttributedString.Key.font: font,
                                        NSAttributedString.Key.foregroundColor: color])
        for str in strings {
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.thick.rawValue, range: (string as NSString).range(of: str))
            attributedString.addAttribute(NSAttributedString.Key.underlineColor, value: UIColor.white, range: (string as NSString).range(of: str))
        }
        return attributedString
    }
}
