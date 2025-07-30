//
//  PhoneNumberTextField.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 30.07.2025.
//

import UIKit

final class PhoneNumberTextField: UITextField {
    // MARK: - Init
    
    init(
        placeholder: String,
        keyboardType: UIKeyboardType = .default
    ) {
        super.init(frame: .zero)
        setupTextField(
            placeholder: placeholder,
            keyboardType: keyboardType
        )
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override
    
    // placeholder position
     override func textRect(forBounds bounds: CGRect) -> CGRect {
         return bounds.insetBy(dx: .inset, dy: .inset)
     }

     // text position
     override func editingRect(forBounds bounds: CGRect) -> CGRect {
         return bounds.insetBy(dx: .inset, dy: .inset)
     }
    
    // MARK: - Private Methods
    
    private func setupTextField(placeholder: String, keyboardType: UIKeyboardType) {
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc
    private func textFieldDidChange() {
        guard let text = self.text else { return }
        self.text = text.applyPhoneNumberMask()
    }
}

extension PhoneNumberTextField: UITextFieldDelegate {
    /// Маска для номера телефона
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//            let char = string.cString(using: String.Encoding.utf8)!
//            let isBackSpace = strcmp(char, "\\b")
//            
//            if (isBackSpace == -92) && (textField.text?.count)! > 0 {
//                if (textField.text?.count)! == 4 {
//                    textField.text = "+7"
//                    return false
//                }
//                if textField.text! == "+7" {
//                    return false
//                }
//                textField.text!.removeLast()
//                return false
//            }
//            
//            if (textField.text?.count)! == 5 {
//                let text = textField.text!.replacingOccurrences(of: "+7", with: "")
//                textField.text = "+7(\(text)) "  //There we are ading () and space two things
//            }
//            else if (textField.text?.count)! == 11 {
//                let text = textField.text!.replacingOccurrences(of: "+7", with: "")
//                textField.text = "+7\(text)-" //there we are ading - in textfield
//            }
//            else if (textField.text?.count)! > 15 {
//                return false
//            }
//        return true
        guard let currentText = textField.text else { return true }
        
        // Разрешаем удаление (backspace)
        if string.isEmpty { return true }
        
        // Проверяем, что вводится цифра
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        if !allowedCharacters.isSuperset(of: characterSet) {
            return false
        }
        
        // Ограничиваем длину номера (10 цифр без маски)
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        let cleanNumber = newText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return cleanNumber.count <= 10
    }
}

private extension CGFloat {
    static let inset: CGFloat = 8
}






class PhoneNumberTextFieldV2: UITextField, UITextFieldDelegate {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextField()
    }
    
    private func setupTextField() {
        self.delegate = self
        self.keyboardType = .phonePad
        self.placeholder = "(XXX) - XXX - XX - XX"
        self.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange() {
        guard let text = self.text else { return }
        self.text = text.applyPhoneNumberMask()
    }
    
    // Ограничиваем ввод только цифрами и управляем курсором
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return true }
        
        // Разрешаем удаление (backspace)
        if string.isEmpty { return true }
        
        // Проверяем, что вводится цифра
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        if !allowedCharacters.isSuperset(of: characterSet) {
            return false
        }
        
        // Ограничиваем длину номера (10 цифр без маски)
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        let cleanNumber = newText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return cleanNumber.count <= 10
    }
}
