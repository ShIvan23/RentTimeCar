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
    private let authService = AuthService.shared

    // MARK: - UI
    
    private let contentView = UIView()
    private let rightActionView = UIView()
    private let needSignUpView = NeedSignUpView()
    private let headerView = SideMenuHeaderView()
    private let logoutButton = MainButton(title: "Выйти")
    private lazy var bannedView = BannedView(coordinator: coordinator)
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
        contentView.addSubviews([needSignUpView, bannedView, sideMenuContentView, headerView, logoutButton])
        setupLogoutButton()
        subscribeToAuthService()
        configureVisibleView(for: AuthService.shared.authState)
        setupPanGesture()
        needSignUpView.delegate = self
        rightActionView.addTapGestureClosure { [weak self] in
            self?.delegate?.needHideSideMenuView()
        }
    }

    private func setupLogoutButton() {
        logoutButton.action = { [weak self] in
            self?.authService.logout()
            self?.delegate?.needHideSideMenuView()
        }
    }

    private func subscribeToAuthService() {
        authService.addObserver(self)
    }

    private func configureVisibleView(for state: AuthState) {
        switch state {
        case .needAuthorize:
            needSignUpView.configure(with: .authorization)
            needSignUpView.isHidden = false
            bannedView.isHidden = true
        case .needRegister:
            needSignUpView.configure(with: .registration)
            needSignUpView.isHidden = false
            bannedView.isHidden = true
        case .onCheck, .fullAccess:
            needSignUpView.isHidden = true
            bannedView.isHidden = true
        case .banned:
            needSignUpView.isHidden = true
            bannedView.isHidden = false
        }
        logoutButton.isHidden = state == .needAuthorize
        headerView.isHidden = state == .needAuthorize
        if state != .needAuthorize {
            let name = [authService.client?.name.firstName, authService.client?.name.lastName]
                .compactMap { $0 }
                .filter { !$0.isEmpty }
                .joined(separator: " ")
            headerView.configure(
                phone: authService.phoneNumber,
                name: name.isEmpty ? nil : name
            )
        }
        sideMenuContentView.updateTableView(isUserLogin: state != .needAuthorize)
        setNeedsLayout()
    }
    
    private func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        addGestureRecognizer(panGesture)
    }
    
    private func performLayout() {
        let state = AuthService.shared.authState
        contentView.pin
            .all()
            .marginRight(bounds.width * 0.13)

        rightActionView.pin
            .vertically()
            .after(of: contentView)
            .right()

        switch state {
        case .needAuthorize:
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
        case .needRegister:
            headerView.pin
                .top(safeAreaInsets.top)
                .horizontally()
                .sizeToFit(.width)

            logoutButton.pin
                .horizontally(16)
                .bottom()
                .marginBottom(safeAreaInsets.bottom)
                .height(50)

            needSignUpView.pin
                .horizontally()
                .above(of: logoutButton)
                .marginBottom(20)
                .sizeToFit(.width)

            sideMenuContentView.pin
                .below(of: headerView)
                .horizontally()
                .bottom(to: needSignUpView.edge.top)
        case .banned:
            headerView.pin
                .top(safeAreaInsets.top)
                .horizontally()
                .sizeToFit(.width)

            logoutButton.pin
                .horizontally(16)
                .bottom()
                .marginBottom(safeAreaInsets.bottom)
                .height(50)

            bannedView.pin
                .horizontally()
                .above(of: logoutButton)
                .sizeToFit(.width)

            sideMenuContentView.pin
                .below(of: headerView)
                .horizontally()
                .bottom(to: bannedView.edge.top)
        case .onCheck, .fullAccess:
            headerView.pin
                .top(safeAreaInsets.top)
                .horizontally()
                .sizeToFit(.width)

            logoutButton.pin
                .horizontally(16)
                .bottom()
                .marginBottom(safeAreaInsets.bottom)
                .height(50)

            sideMenuContentView.pin
                .below(of: headerView)
                .horizontally()
                .bottom(to: logoutButton.edge.top)
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
    func post(state: AuthState) {
        configureVisibleView(for: state)
    }
}
