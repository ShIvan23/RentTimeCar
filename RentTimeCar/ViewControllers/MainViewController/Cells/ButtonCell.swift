//
//  ButtonCell.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 13.08.2025.
//

import PinLayout
import UIKit

final class ButtonCell: UICollectionViewCell {
    // MARK: - UI
    
    private let button = MainButton(title: "Войти")
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        autoSizeThatFits(size, layoutClosure: performLayout)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        performLayout()
    }
    
    // MARK: - Private Methods

    private func setupView() {
        contentView.addSubview(button)
        contentView.backgroundColor = .mainBackground
        button.isUserInteractionEnabled = false
    }
    
    private func performLayout() {
        button.pin
            .all()
            .marginHorizontal(12)
            .marginVertical(4)
    }
}
