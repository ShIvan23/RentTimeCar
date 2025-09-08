//
//  TitleCell.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 15.08.2025.
//

import PinLayout
import UIKit

final class TitleCell: UICollectionViewCell {
    // MARK: - UI
    
    private let label = Label(textAlignment: .left)
    
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
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        performLayout()
    }
    
    // MARK: - Internal Methods
    
    func configure(with text: String) {
        label.text = text
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        contentView.addSubview(label)
        contentView.backgroundColor = .clear
    }
    
    private func performLayout() {
        label.pin.all()
    }
}
