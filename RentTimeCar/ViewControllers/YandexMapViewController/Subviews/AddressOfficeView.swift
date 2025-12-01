//
//  AddressOfficeView.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 22.11.2025.
//

import PinLayout
import UIKit

final class AddressOfficeView: UIView {
    // MARK: - UI
    
    private let title = Label(
        text: .title,
        numberOfLines: 2
    )
    
    private let subtitle = Label(
        text: .subtitle,
        fontSize: 13,
        textColor: .secondaryTextColor
    )
    
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
        addSubviews([title, subtitle])
    }
    
    private func performLayout() {
        title.pin
            .top()
            .horizontally()
            .sizeToFit(.width)
        
        subtitle.pin
            .below(of: title)
            .horizontally()
            .marginTop(4)
            .bottom()
            .sizeToFit(.width)
    }
}

private extension String {
    static let title = "Москва, улица Маршала Рыбалко д2 к6, подъезд 5 офис 106"
    static let subtitle = "09:00 - 21:00 (ежедневно)"
}
