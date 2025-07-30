//
//  String+Extension.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 30.07.2025.
//

import Foundation

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
