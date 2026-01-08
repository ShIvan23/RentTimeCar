//
//  BottomSheetFilterView.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 02.12.2025.
//

import PinLayout
import UIKit

final class BottomSheetFilterViewController: UIViewController {

    // MARK: - UI

    private let tableView = UITableView()
    private lazy var confirmButton = MainButton(title: "Выбрать")

    // MARK: - Private Properties

    private var items: [FilterInfoAuto]
    private var selectedItems: [String]
    private let type: BottomSheetType
    private let coordinator: ICoordinator
    private let filterService = FilterService.shared

    // MARK: - Init

    init(
        type: BottomSheetType,
        coordinator: ICoordinator
    ) {
        items = type.makeModel()
        selectedItems = items.compactMap { $0.isSelected ? $0.name : nil }
        self.type = type
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        tableView.allowsMultipleSelection = type == .autoType
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle

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
        setupTableView()
        view.addSubviews([tableView, confirmButton])
        confirmButton.action = { [weak self] in
            self?.coordinator.dismissViewController()
        }
        confirmButton.isHidden = type == .sorting
    }

    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.contentInset = .init(top: 20)
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }

    private func performLayout() {
        if !confirmButton.isHidden {
            confirmButton.pin
                .bottom()
                .horizontally()
                .marginHorizontal(20)
                .marginBottom(view.safeAreaInsets.bottom)
                .height(50)
        }

        tableView.pin
            .all()
    }
}

// MARK: - UITableViewDataSource

extension BottomSheetFilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[indexPath.row].name

        cell.textLabel?.text = item

        if selectedItems.contains(item) {
            cell.accessoryType = .checkmark
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            cell.accessoryType = .none
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension BottomSheetFilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = items[indexPath.row]

        if !selectedItems.contains(selectedItem.name) {
            selectedItems.append(selectedItem.name)
            let newItem = FilterInfoAuto(
                name: selectedItem.name,
                isSelected: true
            )
            filterService.updateFilterInfo(for: type, item: newItem)
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .checkmark
            }
        } else {
            guard let index = selectedItems.firstIndex(of: selectedItem.name) else { return }
            selectedItems.remove(at: index)
            let newItem = FilterInfoAuto(
                name: selectedItem.name,
                isSelected: false
            )
            filterService.updateFilterInfo(for: type, item: newItem)
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .none
            }
        }

        if !tableView.allowsMultipleSelection {
            coordinator.dismissViewController()
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deselectedItem = items[indexPath.row]

        if let index = selectedItems.firstIndex(of: deselectedItem.name) {
            selectedItems.remove(at: index)
            let newItem = FilterInfoAuto(
                name: deselectedItem.name,
                isSelected: false
            )
            filterService.updateFilterInfo(for: type, item: newItem)
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .none
            }
        }
    }
}
