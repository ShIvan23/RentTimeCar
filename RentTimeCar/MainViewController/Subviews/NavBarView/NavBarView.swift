//
//  NavBarView.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 13.08.2025.
//

import PinLayout
import UIKit

protocol NavBarViewDelegate: AnyObject {
    func menuButtonTupped()
}

final class NavBarView: UIView {
    // MARK: - Internal Properties
    
    weak var delegate: NavBarViewDelegate?
    
    // MARK: - UI
    
    private let menuButton = IconButton(image: .menu)
    
    // MARK: Init
    
    init() {
        super.init(frame: .zero)
        setupView()
        setMenuButtonAction()
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
        addSubview(menuButton)
        backgroundColor = .mainBackground
    }
    
    private func setMenuButtonAction() {
        menuButton.action = { [weak self] in
            self?.delegate?.menuButtonTupped()
        }
    }
    
    private func performLayout() {
        menuButton.pin
            .left()
            .marginLeft(16)
            .size(CGSize(square: 24))
            .vCenter()
    }
}
