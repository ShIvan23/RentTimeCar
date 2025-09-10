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
    func sideMenuDidHide()
}

// Боковая view на главном экране
final class SideMenuView: UIView {
    // MARK: - Internal Properties
    
    weak var delegate: SideMenuViewDelegate?
    
    // MARK: - Private Properties
    
    private let coordinator: ICoordinator
    private let rentApiFacade: IRentApiFacade
    private let isUserLogin = true
    
    // MARK: - UI
    
    private let contentView = UIView()
    private let rightActionView = UIView()
    private let needSignUpView = NeedSignUpView()
    private let sideMenuContentView = SideMenuContentView()
    
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
        contentView.backgroundColor = .mainBackground
        addSubviews([contentView, rightActionView])
        contentView.addSubviews([needSignUpView, sideMenuContentView])
        configureVisibleView()
        setupPanGesture()
        needSignUpView.delegate = self
        rightActionView.addTapGestureClosure { [weak self] in
            self?.delegate?.didTapToEmptySpace()
        }
    }
    
    private func configureVisibleView() {
        if isUserLogin {
            needSignUpView.isHidden = true
        } else {
            sideMenuContentView.isHidden = true
        }
    }
    
    private func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        addGestureRecognizer(panGesture)
    }
    
    private func performLayout() {
        contentView.pin
            .all()
            .marginRight(bounds.width * 0.13)
        
        rightActionView.pin
            .vertically()
            .after(of: contentView)
            .right()
        
        if isUserLogin {
            sideMenuContentView.pin
                .all(pin.safeArea)
        } else {
            needSignUpView.pin
                .horizontally()
                .vCenter()
                .sizeToFit(.width)
        }
    }
    
    @objc
    private func panAction(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: self)
            let newX = frame.origin.x + translation.x
            if newX >= .zero {
                frame.origin.x = .zero
            } else {
                frame.origin.x = newX
            }
            gesture.setTranslation(.zero, in: self)
        case .ended:
            let currentX = frame.origin.x
            let fifthViewWidth = bounds.width / 5
            let isHideAnimation = currentX < -fifthViewWidth
            if !isHideAnimation {
                UIView.animate(withDuration: 0.5) {
                    self.frame.origin.x = .zero
                }
            } else {
                delegate?.sideMenuDidHide()
            }
        default:
            break
        }
    }
}

extension SideMenuView: NeedSignUpViewDelegate {
    func signUpButtonTapped() {
        coordinator.openAuthorization()
    }
}
