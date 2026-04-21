//
//  EnterCodeView.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 17.12.2025.
//

import UIKit

protocol EnterCodeViewDelegate: AnyObject {
    func validateCode(_ code: String)
}

final class EnterCodeView: UIView {
    // MARK: - Private Properties

    private weak var delegate: EnterCodeViewDelegate?

    // MARK: - UI

    private let stackView = ManualLayoutBasedStackView()
    private var codeTextFieldsPool = [CodeTextField]()

    // MARK: - Init

    init(delegate: EnterCodeViewDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override public func layoutSubviews() {
        super.layoutSubviews()
        performLayout()
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        autoSizeThatFits(size, layoutClosure: performLayout)
    }

    // MARK: - Private Methods

    private func setupView() {
        addSubview(stackView)
        configureStackView()
    }

    private func configureStackView() {
        stackView.axis = .horizontal
        stackView.spacing = .stackViewSpacing
        for _ in 0...4 {
            let codeTextField = CodeTextField(codeDelegate: self)
            codeTextFieldsPool.append(codeTextField)
            stackView.addArrangedSubview(codeTextField)
        }
    }

    private func performLayout() {
        stackView.pin.all()
    }

    private func validateCode() {
        var code = ""
        codeTextFieldsPool.forEach {
            code += $0.text ?? ""
        }
        delegate?.validateCode(code)
    }
}

extension EnterCodeView: CodeTextFieldDelegate {
    func didEnterNumber(_ textField: CodeTextField) {
        guard let currentTextFieldIndex = codeTextFieldsPool.firstIndex(where: { $0 === textField }),
              let nextTextField = codeTextFieldsPool[safe: currentTextFieldIndex + 1] else { return validateCode() }
        nextTextField.becomeFirstResponder()
    }

    func didEnterNumberInFilledField(_ textField: CodeTextField, digit: String) {
        guard let currentTextFieldIndex = codeTextFieldsPool.firstIndex(where: { $0 === textField }),
              let nextTextField = codeTextFieldsPool[safe: currentTextFieldIndex + 1],
              nextTextField.text?.isEmpty == true else { return }
        nextTextField.text = digit
        didEnterNumber(nextTextField)
    }

    func didDeleteNumber(_ textField: CodeTextField) {
        guard let currentTextFieldIndex = codeTextFieldsPool.firstIndex(where: { $0 === textField }),
              let previousTextField = codeTextFieldsPool[safe: currentTextFieldIndex - 1] else { return }
        previousTextField.becomeFirstResponder()
    }

    func didAutofillCode(_ code: String) {
        let digits = code.filter(\.isNumber)
        for (index, field) in codeTextFieldsPool.enumerated() {
            guard index < digits.count else { break }
            field.text = String(digits[digits.index(digits.startIndex, offsetBy: index)])
        }
        codeTextFieldsPool.last?.resignFirstResponder()
        validateCode()
    }
}

private extension CGFloat {
    static let stackViewSpacing: CGFloat = 10
}
