//
//  BottomSheetFilterView.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 02.12.2025.
//

import UIKit

final class BottomSheetFilterViewController: UITableViewController {

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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.contentInset = .init(top: 20)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = items[indexPath.row]

        if !selectedItems.contains(selectedItem.name) {
            selectedItems.append(selectedItem.name)
            let newItem = FilterInfoAuto(
                name: selectedItem.name,
                isSelected: true
            )
            filterService.updateFilterInfo(for: type, item: newItem)
        }
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        if !tableView.allowsMultipleSelection {
            coordinator.dismissViewController()
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deselectedItem = items[indexPath.row]

        if let index = selectedItems.firstIndex(of: deselectedItem.name) {
            selectedItems.remove(at: index)
            let newItem = FilterInfoAuto(
                name: deselectedItem.name,
                isSelected: false
            )
            filterService.updateFilterInfo(for: type, item: newItem)
        }
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
}
