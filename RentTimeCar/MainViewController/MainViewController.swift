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
    private var autos: [Autos] = []
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CarCell.self, forCellWithReuseIdentifier: CarCell.identifier)
        return collectionView
    }()
    
    // MARK: - Private Properties
    
    private let coordinator: ICoordinator
    private let rentApiFacade: IRentApiFacade
    private var isShowSideMenu = false
    
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
        fetchAutos()
        getUserInfo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        performLayout()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        view.backgroundColor = .purple
        view.addSubviews([menuButton, transparentView, collectionView, sideMenuView])
        sideMenuView.delegate = self
        transparentView.isHidden = true
        setMenuButtonAction()
    }
    
    private func getUserInfo() {
//        rentApiFacade.getClients(with: <#T##String#>, completion: <#T##(Result<ApiResult<Clients>, any Error>) -> Void#>)
        
        // надо где-то прихранивать номер телефона пользователя
    }
    
    private func performLayout() {
        isShowSideMenu ? showLayoutSideMenu() : hiddenLayoutSideMenu()
        layoutMenuButton()
        layoutCarCollection()
    }
    
    private func fetchAutos() {
        rentApiFacade.getAutos { [weak self] result in
            switch result {
            case .success(let model):
                DispatchQueue.main.async {
                    self?.autos = model.result ?? []
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print("Ошибка: \(error.localizedDescription)")
            }
        }
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
        navigationController?.navigationBar.isHidden = true
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
        isShowSideMenu = !isHidden
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
    
    private func hiddenLayoutSideMenu() {
        sideMenuView.frame = CGRect(
            x: -view.bounds.width,
            y: .zero,
            width: view.bounds.width,
            height: view.bounds.height
        )
        
        transparentView.frame = view.bounds
    }
    
    private func showLayoutSideMenu() {
        sideMenuView.frame.origin = .zero
    }

    private func layoutCarCollection() {
        collectionView.pin
            .top(view.safeAreaInsets.top)
            .horizontally()
            .bottom()
    }
}

// MARK: - SideMenuViewDelegate

extension MainViewController: SideMenuViewDelegate {
    func didTapToEmptySpace() {
        guard sideMenuView.frame.origin.x == .zero else { return }
        animateSideMenu(isHidden: true)
    }
    
    func sideMenuDidHide() {
        animateSideMenu(isHidden: true)
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return autos.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarCell.identifier, for: indexPath) as? CarCell
        else {
            return  UICollectionViewCell()
        }
        let auto = autos[indexPath.item]
        cell.configure(model: auto)
        return cell
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.bounds.width
        return CGSize(width: cellWidth, height: cellWidth * 0.75 )
    }
}


// MARK: - TimeInterval

private extension TimeInterval {
    static let animationTime: TimeInterval = 0.5
}
