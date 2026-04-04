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
        numberOfLines: 2
    )
    
    private let subtitle = Label(
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

    // MARK: - Internal Methods

    func getAddress() -> String {
        guard let address = title.text else { return "" }
        return address
    }

    func configure(with officeAddress: OfficeAddress) {
        title.text = officeAddress.address
        subtitle.text = officeAddress.workingHours
        setNeedsLayout()
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
