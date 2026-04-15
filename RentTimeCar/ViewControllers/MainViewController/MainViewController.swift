//
//  ViewController.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 28.07.2025.
//

import Nuke
import PinLayout
import UIKit

import NukeExtensions

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
        collectionView.prefetchDataSource = self
        collectionView.register(cell: ButtonCell.self)
        collectionView.register(cell: CarCell.self)
        collectionView.register(cell: EmptyCell.self)
        collectionView.register(cell: ShimmerCarCell.self)
        return collectionView
    }()
    
    // MARK: - Private Properties
    
    private var cells: [CellType] = []
    private let coordinator: ICoordinator
    private let rentApiFacade: IRentApiFacade
    private let filterService = FilterService.shared
    private let authService = AuthService.shared
    private lazy var imagePrefetcher = ImagePrefetcher(pipeline: ImagePipeline.shared)
    private let refreshControl = UIRefreshControl()
    private var isShowSideMenu = false
    private var collectionViewContentYOffset: CGFloat = .zero
    private var filterViewIsHidden = false {
        didSet {
            if oldValue != filterViewIsHidden {
                UIView.animate(withDuration: 0.5) {
                    self.view.setNeedsLayout()
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    // MARK: - Init

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
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        showShimmer()
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
        filterView.isHidden = true
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        subscribeToNotification()
    }
    
    private func performLayout() {
        isShowSideMenu ? showLayoutSideMenu() : hiddenLayoutSideMenu()
        layoutNavBarView()
        layoutCarCollection()
        layoutFilterView()
    }
    
    private func subscribeToNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(filteredAutosUpdated), name: .filteredAutosUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(filteredAutosUpdated), name: .sortingAutoUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(filteredAutosUpdated), name: .classAutoUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onAutoSearchStarted), name: .autoSearchStarted, object: nil)
        AuthService.shared.addObserver(self)
    }

    @objc
    private func onAutoSearchStarted() {
        DispatchQueue.main.async { self.showShimmer() }
    }

    @objc
    private func handleRefresh() {
        refreshControl.endRefreshing()
        showShimmer()
        authService.refreshAuthState()
        fetchAutos()
    }

    @objc
    private func filteredAutosUpdated() {
        DispatchQueue.main.async {
            let model = self.filterService.filteredAutos
            if model.isEmpty {
                self.cells = self.mapAutos(with: self.filterService.allAutos)
            } else {
                self.cells = self.mapAutos(with: model)
            }
            self.collectionView.reloadData()
        }
    }

    private func showShimmer() {
        cells = [.empty(.emptyCellHeight)] + Array(repeating: .shimmer, count: 5)
        collectionView.reloadData()
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
            DispatchQueue.main.async {
                guard let self else { return }
                self.refreshControl.endRefreshing()
            }
            switch result {
            case .success(let model):
                DispatchQueue.main.async {
                    guard let self else { return }
                    self.cells = self.mapAutos(with: model.result ?? [])
                    self.collectionView.reloadData()
                    self.filterService.setModel(model.result ?? [])
                    self.filterView.isHidden = model.result?.isEmpty ?? true
                    self.view.setNeedsLayout()
                }
            case .failure:
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    let model = InfoBottomSheetModel(
                        text: "Ошибка при загрузке",
                        image: .redCross,
                        buttonTitle: "Повторить",
                        onConfirm: { [weak self] in self?.fetchAutos() }
                    )
                    self.coordinator.openInfoBottomSheetViewController(model: model)
                }
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
        switch authService.authState {
        case .needAuthorize:
            result.insert(.button(.authorization), at: 2)
        case .needRegister:
            result.insert(.button(.registration), at: 2)
        case .onCheck:
            result.insert(.button(.onCheck), at: 2)
        case .fullAccess:
            break
        case .banned:
            break
        }
        return result
    }
}

// MARK: - Filter View

extension MainViewController {
    private func layoutFilterView() {
        guard !filterView.isHidden else { return }
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
    private func animateSideMenu(isHidden: Bool, completion: (() -> Void)? = nil) {
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
            completion?()
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
    func needHideSideMenuView() {
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
        case let .button(buttonType):
            let cell: ButtonCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(with: buttonType)
            return cell
        case let .car(autoModel):
            let cell: CarCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(model: autoModel)
            return cell
        case .shimmer:
            let cell: ShimmerCarCell = collectionView.dequeueCell(for: indexPath)
            return cell
        }
    }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension MainViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urlsForPrefetch: [URL] = indexPaths.compactMap {
            guard case let .car(autoModel) = cells[$0.item],
                  let urlString = autoModel.files.first?.url,
                  let url = URL(string: urlString) else { return nil }
            return url
        }
        imagePrefetcher.startPrefetching(with: urlsForPrefetch)
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
            return CGSize(width: cellWidth, height: cellWidth * 0.75)
        case .shimmer:
            return CGSize(width: cellWidth, height: cellWidth * 0.75)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch cells[indexPath.item] {
        case let .car(autoModel):
            coordinator.openDetailAutoCar(model: autoModel)
        case let .button(buttonType):
            switch buttonType {
            case .authorization:
                coordinator.openAuthorization()
            case .registration:
                coordinator.openRegistrationViewController()
            case .onCheck:
                print("+++ show onCheck screen")
                break
            }
        case .empty, .shimmer:
            break
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
        
        collectionViewContentYOffset = scrollView.contentOffset.y
    }
}

// MARK: - AuthServiceObserver

extension MainViewController: AuthServiceObserver {
    func post(state: AuthState) {
        switch state {
        case .needAuthorize:
            showAuthorizationButton()
        case .needRegister:
            showRegistrationButton()
        case .onCheck:
            showOnCheckButton()
        case .fullAccess:
            removeAllButtons()
        case .banned:
            removeAllButtons()
        }
        animateSideMenu(isHidden: true) { [weak self] in
            self?.coordinator.popToRootViewController()
        }
    }

    private func showAuthorizationButton() {
        removeAllButtons()
        guard cells.count >= 2 else { return }
        cells.insert(.button(.authorization), at: 2)
        collectionView.reloadData()
    }

    private func showRegistrationButton() {
        removeAllButtons()
        guard cells.count >= 2 else { return }
        cells.insert(.button(.registration), at: 2)
        collectionView.reloadData()
    }

    private func showOnCheckButton() {
        removeAllButtons()
        guard cells.count >= 2 else { return }
        cells.insert(.button(.onCheck), at: 2)
        collectionView.reloadData()
    }

    private func removeAllButtons() {
        guard let firstButtonCellIndex = cells.firstIndex(where: {
            if case .button = $0 {
                return true
            } else {
                return false
            }
        }) else { return }
        cells.remove(at: firstButtonCellIndex)
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
        case button(ButtonType)
        case shimmer

        enum ButtonType: String {
            case authorization = "Войти"
            case registration = "Зарегистрироваться"
            case onCheck = "Ожидайте проверки документов"
        }
    }
}
