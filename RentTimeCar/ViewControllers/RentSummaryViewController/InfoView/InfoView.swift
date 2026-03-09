//
//  InfoView.swift
//  RentTimeCar
//
//  Created by Андрей Пермяков on 13.02.2026.
//

import UIKit
import PinLayout

final class InfoView: UIView {

    // MARK: - Private Properties
    private let contentView = InfoViewContentView()
    private var anchorFrame: CGRect?
    private let widthRatio: CGFloat = 0.7

    // MARK: - Init
    init(text: String) {
        super.init(frame: .zero)
        setupViews()
        contentView.configure(text: text)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override Methods
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let anchorFrame = self.anchorFrame else { return }
        let maxWidth = bounds.width * widthRatio
        let size = contentView.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude) )
        
        let x = anchorFrame.midX - size.width / 2
        let y = anchorFrame.minY - size.height - 8
        
        contentView.pin
            .size(size)
            .top(y)
            .left(x)
        
        if contentView.frame.minX < 16 {
            contentView.pin.left(16)
        }
        if contentView.frame.maxX > bounds.width - 16 {
            contentView.pin.right(16)
        }
    }

    // MARK: - Internal Methods
    func show(anchorFrame: CGRect) {
        self.anchorFrame = anchorFrame
        isHidden = false
        alpha = 0
        UIView.animate(withDuration: 0.3) { self.alpha = 1 }
    }

    func hide() {
        UIView.animate(withDuration: 0.3) { self.alpha = 0 } completion: { _ in self.isHidden = true }
    }

    // MARK: - Private Methods
    private func setupViews() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubviews([contentView])
        addTapGestureClosure { [weak self] in self?.hide() }
    }
}
