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
    private let navBarView = NavBarView()
    private lazy var filterView = FilterView(coordinator: coordinator)
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .mainBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cell: ButtonCell.self)
        collectionView.register(cell: CarCell.self)
        collectionView.register(cell: EmptyCell.self)
        return collectionView
    }()
    
    // MARK: - Private Properties
    
    private var cells: [CellType] = []
    private let coordinator: ICoordinator
    private let rentApiFacade: IRentApiFacade
    private var isShowSideMenu = false
    private var collectionViewContentYOffset: CGFloat = .zero
    private var filterViewIsHidden = false
    
    // MARK: Init
    
    init(
        coordinator: ICoordinator,
        rentApiFacade: IRentApiFacade
    ) {
        self.coordinator = coordinator
        self.rentApiFacade = rentApiFacade
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fetchAutos()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        performLayout()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        view.backgroundColor = .mainBackground
        view.addSubviews([collectionView, filterView, navBarView, transparentView, sideMenuView])
        sideMenuView.delegate = self
        navBarView.delegate = self
        transparentView.isHidden = true
    }
    
    private func performLayout() {
        isShowSideMenu ? showLayoutSideMenu() : hiddenLayoutSideMenu()
        layoutNavBarView()
        layoutCarCollection()
        layoutFilterView()
    }
}

// MARK: - CollectionView

extension MainViewController {
    private func layoutCarCollection() {
        collectionView.pin
            .below(of: navBarView)
            .horizontally()
            .bottom()
    }
    
    private func fetchAutos() {
        rentApiFacade.getAutos { [weak self] result in
            switch result {
            case .success(let model):
                DispatchQueue.main.async {
                    guard let self else { return }
                    self.cells = self.mapAutos(with: model.result ?? [])
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                print("Ошибка: \(error.localizedDescription)")
            }
        }
    }

    private func mapAutos(with model: [Auto]) -> [CellType] {
        var result = [CellType]()
        guard !model.isEmpty else { return result }
        result = model.map {
            .car($0)
        }
        result.insert(.empty(.emptyCellHeight), at: .zero)
        // TODO: - Тут нужна логика на авторизованного пользователя
        result.insert(.button, at: 2)
        return result
    }
}

// MARK: - Filter View

extension MainViewController {
    private func layoutFilterView() {
        if filterViewIsHidden {
            filterView.pin
                .top(view.safeAreaInsets.top)
                .horizontally()
                .height(.emptyCellHeight)
        } else {
            filterView.pin
                .below(of: navBarView)
                .horizontally()
                .height(.emptyCellHeight)
        }
    }
}

// MARK: - NavBarView

extension MainViewController {
    private func layoutNavBarView() {
        navigationController?.isNavigationBarHidden = true
        let navigationBarFrame = navigationController?.navigationBar.frame ?? .zero
        navBarView.pin
            .top(view.safeAreaInsets.top)
            .horizontally()
            .height(navigationBarFrame.height)
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

// MARK: - NavBarViewDelegate

extension MainViewController: NavBarViewDelegate {
    func menuButtonTupped() {
        animateSideMenu(isHidden: false)
    }
}

// MARK: - UICollectionViewDataSource

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cells[indexPath.item]
        switch cell {
        case .empty:
            let cell: EmptyCell = collectionView.dequeueCell(for: indexPath)
            return cell
        case .button:
            let cell: ButtonCell = collectionView.dequeueCell(for: indexPath)
            return cell
        case let .car(autoModel):
            let cell: CarCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(model: autoModel)
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.bounds.width
        let cell = cells[indexPath.item]
        switch cell {
        case let .empty(height):
            return CGSize(width: cellWidth, height: height)
        case .button:
            return CGSize(width: cellWidth, height: 58)
        case .car:
            return CGSize(width: cellWidth, height: cellWidth * 0.75 )
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentOffset.y > scrollView.contentInset.top else {
            // bouncing on top
            filterViewIsHidden = false
            return
        }
        
        guard scrollView.contentOffset.y < (scrollView.contentSize.height - scrollView.bounds.size.height) else {
            // bouncing on bottom
            filterViewIsHidden = false
            return
        }
        
        if collectionViewContentYOffset > scrollView.contentOffset.y {
            filterViewIsHidden = false
        } else {
            filterViewIsHidden = true
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
        collectionViewContentYOffset = scrollView.contentOffset.y
    }
}

// MARK: - TimeInterval

private extension TimeInterval {
    static let animationTime: TimeInterval = 0.5
}

// MARK: - TimeInterval

extension CGFloat {
    static let emptyCellHeight: CGFloat = 50
}

// MARK: - CellType

extension MainViewController {
    enum CellType {
        case car(Auto)
        case empty(_ height: CGFloat)
        case button
    }
}
