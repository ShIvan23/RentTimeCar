//
//  PhoneNumberTextField.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 30.07.2025.
//

import UIKit

final class PhoneNumberTextField: UITextField {
    // MARK: - Private Properties
    
    private let placeHolderText = "000-000-00-00"
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        setupTextField()
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
    
    // MARK: - Internal Methods
    
    func validatePhone() -> Bool {
        guard let text else { return false }
        let cleanedPhone = text.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
            
            // Проверяем длину номера и префикс
            guard cleanedPhone.count == 10 else { return false }
            
            // Проверяем начало номера (7 или 8) и следующую цифру (обычно 9 для мобильных)
            guard let firstDigit = cleanedPhone.first else { return false }
            
            return (firstDigit == "9" || firstDigit == "8")
    }
    
    // MARK: - Private Methods
    
    private func setupTextField() {
        self.keyboardType = .numberPad
        font = UIFont.openSans(fontSize: 21)
        addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textColor = .white
        setPlaceholder()
    }
    
    private func setPlaceholder() {
        text = placeHolderText
        textColor = .lightGray
    }
    
    private func setEditingColor() {
        textColor = .white
    }
    
    @objc
    private func textFieldDidChange() {
        guard let text = self.text else { return }
        let maskedText = text.applyPhoneNumberMask()
        self.text = maskedText
    }
}

extension PhoneNumberTextField: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == placeHolderText {
            textField.text = ""
            setEditingColor()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            setPlaceholder()
        }
    }
    
    /// Маска для номера телефона
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return true }
        
        // Разрешаем удаление (backspace)
        if string.isEmpty {
            let textWithOutMask = currentText.cancelPhoneNumberMask()
            let droppedLast = textWithOutMask.dropLast()
            if droppedLast == "" {
                textField.text = ""
                return false
            }
            textField.text = String(droppedLast).applyPhoneNumberMask()
            return false
        }
        
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
