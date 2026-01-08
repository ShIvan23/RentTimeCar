//
//  SideMenuView.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 29.07.2025.
//

import PinLayout
import UIKit

protocol SideMenuViewDelegate: AnyObject {
    func needHideSideMenuView()
    func sideMenuDidHide()
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
    private lazy var sideMenuContentView = SideMenuContentView(
        delegate: self,
        coordinator: coordinator
    )

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
        subscribeToAuthService()
        configureVisibleView(isUserLogin: AuthService.shared.isAuthorized)
        setupPanGesture()
        needSignUpView.delegate = self
        rightActionView.addTapGestureClosure { [weak self] in
            self?.delegate?.needHideSideMenuView()
        }
    }

    private func subscribeToAuthService() {
        AuthService.shared.addObserver(self)
    }

    private func configureVisibleView(isUserLogin: Bool) {
        if isUserLogin {
            needSignUpView.isHidden = true
        } else {
            needSignUpView.isHidden = false
        }
        sideMenuContentView.updateTableView(isUserLogin: isUserLogin)
        setNeedsLayout()
    }
    
    private func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        addGestureRecognizer(panGesture)
    }
    
    private func performLayout() {
        let isUserLogin = AuthService.shared.isAuthorized
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
                .bottom()
                .marginBottom(safeAreaInsets.bottom)
                .sizeToFit(.width)

            sideMenuContentView.pin
                .top()
                .horizontally()
                .marginTop(safeAreaInsets.top)
                .bottom(to: needSignUpView.edge.top)
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

// MARK: - NeedSignUpViewDelegate

extension SideMenuView: NeedSignUpViewDelegate {
    func signUpButtonTapped() {
        coordinator.openAuthorization()
    }
}

// MARK: - NeedSignUpViewDelegate

extension SideMenuView: SideMenuContentViewProtocol {
    func hideSideMenuView() {
        delegate?.needHideSideMenuView()
    }
}

// MARK: - NeedSignUpViewDelegate

extension SideMenuView: AuthServiceObserver {
    func post(isAuthorized: Bool) {
        configureVisibleView(isUserLogin: isAuthorized)
    }
}
