//
//  SideMenuView.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 29.07.2025.
//

import PinLayout
import UIKit

protocol SideMenuViewDelegate: AnyObject {
    func didTapToEmptySpace()
}

// Боковая view на главном экране
final class SideMenuView: UIView {
    // MARK: - Internal Properties
    
    weak var delegate: SideMenuViewDelegate?
    
    // MARK: - Private Properties
    
    private let coordinator: ICoordinator
    private let rentApiFacade: IRentApiFacade
    
    // MARK: - UI
    
    private let contentView = UIView()
    private let rightActionView = UIView()
    private let needSignUpView = NeedSignUpView()
    
    init(
        coordinator: ICoordinator,
        rentApiFacade: IRentApiFacade
    ) {
        self.coordinator = coordinator
        self.rentApiFacade = rentApiFacade
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        performLayout()
    }
    
    private func setupView() {
        contentView.backgroundColor = .black
        addSubviews([contentView, rightActionView])
        contentView.addSubview(needSignUpView)
        needSignUpView.delegate = self
        rightActionView.addTapGestureClosure { [weak self] in
            self?.delegate?.didTapToEmptySpace()
        }
    }
    
    private func performLayout() {
        contentView.pin
            .all()
            .marginRight(bounds.width * 0.13)
        
        rightActionView.pin
            .vertically()
            .after(of: contentView)
            .right()
        
        needSignUpView.pin
            .horizontally()
            .vCenter()
            .sizeToFit(.width)
    }
}

extension SideMenuView: NeedSignUpViewDelegate {
    func signUpButtonTapped() {
        coordinator.openAuthorization()
    }
}
