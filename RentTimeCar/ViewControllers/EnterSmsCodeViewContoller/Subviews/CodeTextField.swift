//
//  CodeTextField.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 17.12.2025.
//

import UIKit

protocol CodeTextFieldDelegate: AnyObject {
    func didEnterNumber(_ textField: CodeTextField)
}

final class CodeTextField: UITextField {
    // MARK: - Private Properties

    private weak var codeDelegate: CodeTextFieldDelegate?

    // MARK: - Init
    init(codeDelegate: CodeTextFieldDelegate) {
        self.codeDelegate = codeDelegate
        super.init(frame: .zero)
        setupTextField()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override

    // text position
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: .inset, dy: .zero)
    }

    // MARK: - Layout

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        CGSize(square: 60)
    }

    // MARK: - Private Methods

    private func setupTextField() {
        backgroundColor = .secondaryBackground
        self.keyboardType = .numberPad
        font = UIFont.openSans(fontSize: 21)
        textColor = .whiteTextColor
        textAlignment = .center
        layer.borderWidth = 2
        layer.borderColor = UIColor.whiteTextColor.cgColor
        layer.cornerRadius = 14
        delegate = self
    }
}

extension CodeTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string != "" else { return true }
        guard textField.text == "" else { return false }
        textField.text = string
        codeDelegate?.didEnterNumber(self)
        return textField.text?.isEmpty == true
    }
}

private extension CGFloat {
    static let inset: CGFloat = 20
}
