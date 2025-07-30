//
//  ViewController.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 28.07.2025.
//

import PinLayout
import UIKit

// Главный контроллер
final class MainViewController: UIViewController {
    // MARK: - UI
    
    private lazy var sideMenuView = SideMenuView(
        coordinator: coordinator,
        rentApiFacade: rentApiFacade
    )
    private let transparentView = UIView()
    private let menuButton = IconButton(image: .menu)
    
    // MARK: - Private Properties
    
    private let coordinator: ICoordinator
    private let rentApiFacade: IRentApiFacade
    
    // MARK: Init
    
    init(
        coordinator: ICoordinator,
        rentApiFacade: IRentApiFacade
    ) {
        self.coordinator = coordinator
        self.rentApiFacade = rentApiFacade
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        performLayout()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        view.backgroundColor = .black
        view.addSubviews([menuButton, transparentView, sideMenuView])
        sideMenuView.delegate = self
        transparentView.isHidden = true
        setMenuButtonAction()
        navigationController?.navigationBar.isHidden = true
    }
    
    private func performLayout() {
        layoutSideMenu()
        layoutMenuButton()
    }
}

// MARK: - MenuButton

extension MainViewController {
    private func layoutMenuButton() {
        let navigationBarFrame = navigationController?.navigationBar.frame ?? .zero
        let menuButtonSize = CGSize(square: 24)
        let menuButtonY = navigationBarFrame.minY + (navigationBarFrame.height - menuButtonSize.height) / 2
        menuButton.frame = CGRect(
            origin: CGPoint(x: 16, y: menuButtonY),
            size: menuButtonSize
        )
    }
    
    private func setMenuButtonAction() {
        menuButton.action = { [weak self] in
            self?.animateSideMenu(isHidden: false)
        }
    }
}

// MARK: - SideMenuView

extension MainViewController {
    private func animateSideMenu(isHidden: Bool) {
        let currentOrigin = CGPoint(
            x: isHidden ? -view.bounds.width : .zero,
            y: .zero
        )
        // если надо показать transparentView, то ее нужно сделать isHidden = fasle до анимации
        if !isHidden {
            transparentView.isHidden = isHidden
        }
        UIView.animate(withDuration: .animationTime) {
            self.sideMenuView.frame.origin = currentOrigin
            self.transparentView.backgroundColor = .black.withAlphaComponent(isHidden ? .zero : 0.6)
        } completion: { _ in
            self.transparentView.isHidden = isHidden
        }
    }
    
    private func layoutSideMenu() {
        sideMenuView.frame = CGRect(
            x: -view.bounds.width,
            y: .zero,
            width: view.bounds.width,
            height: view.bounds.height
        )
        
        transparentView.frame = view.bounds
    }
}

// MARK: - SideMenuViewDelegate

extension MainViewController: SideMenuViewDelegate {
    func didTapToEmptySpace() {
        guard sideMenuView.frame.origin.x == .zero else { return }
        animateSideMenu(isHidden: true)
    }
}

// MARK: - TimeInterval

private extension TimeInterval {
    static let animationTime: TimeInterval = 0.5
}
