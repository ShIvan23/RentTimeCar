//
//  SideMenuContentView.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 01.08.2025.
//

import UIKit

final class SideMenuContentView: UIView {
    // MARK: - UI
    
    private let tableView = UITableView()
    
    // MARK: - Private Properties
    
    private var model = [[SideMenuModel]]()
    
    // MARK: - Init
    
    init() {
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
    
    // MARK: - Private Methods
    
    private func setupView() {
        setupTableView()
        model = SideMenuModel.makeModels()
        tableView.reloadData()
        backgroundColor = .mainBackground
    }
    
    private func setupTableView() {
        addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(cell: SideMenuContentTableViewCell.self)
        tableView.backgroundColor = .clear
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
        switch indexPath.section {
        case 0:
            return 70
        default:
            return 100
        }
    }
}
