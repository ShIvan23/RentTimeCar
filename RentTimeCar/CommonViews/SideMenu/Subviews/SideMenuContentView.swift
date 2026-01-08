//
//  SideMenuContentView.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 01.08.2025.
//

import UIKit

protocol SideMenuContentViewProtocol: AnyObject {
    func hideSideMenuView()
}

// Вьюха в боковом меню, когда пользователь залогинен
final class SideMenuContentView: UIView {
    // MARK: - UI
    
    private let tableView = UITableView()
    
    // MARK: - Private Properties
    
    private var model = [[SideMenuModel]]()
    private let coordinator: ICoordinator
    private weak var delegate: SideMenuContentViewProtocol?

    // MARK: - Init
    
    init(
        delegate: SideMenuContentViewProtocol,
        coordinator: ICoordinator
    ) {
        self.delegate = delegate
        self.coordinator = coordinator
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        autoSizeThatFits(size, layoutClosure: performLayout)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        performLayout()
    }

    // MARK: - Internal Methods

    func updateTableView(isUserLogin: Bool) {
        model = SideMenuModel.makeModels(isAuthorized: isUserLogin)
        tableView.reloadData()
    }

    // MARK: - Private Methods
    
    private func setupView() {
        setupTableView()
        model = SideMenuModel.makeModels(isAuthorized: AuthService.shared.isAuthorized)
        tableView.reloadData()
        backgroundColor = .mainBackground
    }
    
    private func setupTableView() {
        addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(cell: SideMenuContentTableViewCell.self)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
    
    private func performLayout() {
        tableView.pin.all(pin.safeArea)
    }
}

// MARK: - UITableViewDataSource

extension SideMenuContentView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        model.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SideMenuContentTableViewCell = tableView.dequeueCell(for: indexPath)
        cell.configure(with: model[indexPath.section][indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SideMenuContentView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = model[safe: indexPath.section],
              let item = section[safe: indexPath.row] else { return .zero }
        switch item.cellType {
        case .small:
            return 70
        case .big:
            return 100
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = model[safe: indexPath.section]?[safe: indexPath.row] else { return }
        switch item.title {
        case .myRents:
            print("+++ открыть экран со списком аренд")
        case .myFines:
            print("+++ открыть экран со списком штрафов")
        case .mySettings:
            print("+++ открыть экран с настройками")
        case .catalog:
            delegate?.hideSideMenuView()
        case .support:
            coordinator.openContactsViewController()
        }
    }
}
