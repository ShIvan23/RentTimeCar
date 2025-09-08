//
//  FilterValueContainerView.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 15.08.2025.
//

import PinLayout
import UIKit

protocol FilterValueContainerViewDelegate: AnyObject {
    func didEnterNewValue(_ value: Int, type: FilterValueContainerView.FilterValueType)
}

final class FilterValueContainerView: UIView {
    enum FilterValueType: String {
        case from = "от"
        case to = "до"
    }
    
    // MARK: - Internal Properties
    
    weak var delegate: FilterValueContainerViewDelegate?
    
    // MARK: - UI
    
    private let label = Label(textAlignment: .left)
    private let textField = UITextField()
    private let type: FilterValueType
    
    // MARK: - Init
    
    init(type: FilterValueType) {
        self.type = type
        super.init(frame: .zero)
        setupView(type: type)
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
    
    // MARK: - Internal Methods
    
    func configure(value: Int) {
        textField.text = "\(value)"
    }
    
    // MARK: - Private Methods
    
    private func setupView(type: FilterValueType) {
        addSubviews([label, textField])
        layer.cornerRadius = 12
        layer.borderWidth = 2
        layer.borderColor = UIColor.whiteTextColor.cgColor
        label.text = type.rawValue
        textField.textColor = .whiteTextColor
        textField.delegate = self
        textField.keyboardType = .numberPad
    }
    
    private func performLayout() {
        label.pin
            .left()
            .vCenter()
            .marginLeft(12)
            .sizeToFit()
        
        textField.pin
            .vertically()
            .left(to: label.edge.right)
            .right()
            .marginLeft(10)
    }
}

extension FilterValueContainerView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text,
              let intValue = Int(text) else { return }
        delegate?.didEnterNewValue(intValue, type: type)
    }
}
