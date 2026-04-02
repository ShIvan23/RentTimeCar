//
//  FilterView.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 13.08.2025.
//

import PinLayout
import UIKit

// Вьюшка с фильтрами на главном экране
final class FilterView: UIView {
    // MARK: - UI
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .mainBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cell: FilterCell.self)
        return collectionView
    }()
    
    // MARK: - Private Properties
    
    private let coordinator: ICoordinator
    private var filterModel = [FilterModel]()
    
    // MARK: Init
    
    init(coordinator: ICoordinator) {
        self.coordinator = coordinator
        super.init(frame: .zero)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        autoSizeThatFits(size, layoutClosure: performLayout)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        performLayout()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        backgroundColor = .mainBackground
        addSubview(collectionView)
        filterModel = FilterModel.makeFilterModel()
        subscribeNotifications()
    }
    
    private func performLayout() {
        collectionView.pin.all()
            .marginVertical(4)
    }
    
    private func subscribeNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(selectedDatesUpdate),
            name: .selectedDatesUpdated,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(filteredAutosUpdated),
            name: .filteredAutosUpdated,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sortingUpdated),
            name: .sortingAutoUpdated,
            object: nil
        )
    }
    
    @objc
    private func selectedDatesUpdate() {
        let selectedDates = FilterService.shared.selectedDates
        let dateFilterIndex = filterModel.firstIndex {
            switch $0.type {
            case .date: true
            default: false
            }
        }
        guard let dateFilterIndex,
              let oldModel = filterModel[safe: dateFilterIndex] else { return }
        filterModel[dateFilterIndex] = FilterModel(
            type: oldModel.type,
            image: oldModel.image,
            text: oldModel.text,
            isSelected: !selectedDates.isEmpty
        )

        let filterCellIndex = filterModel.firstIndex {
            switch $0.type {
            case .filter: true
            default: false
            }
        }
        if let filterCellIndex, let oldFilterModel = filterModel[safe: filterCellIndex] {
            filterModel[filterCellIndex] = FilterModel(
                type: oldFilterModel.type,
                image: oldFilterModel.image,
                text: oldFilterModel.text,
                isSelected: FilterService.shared.hasFilters
            )
        }

        collectionView.reloadData()
    }
    
    @objc
    private func sortingUpdated() {
        let sortIndex = filterModel.firstIndex {
            switch $0.type {
            case .sort: true
            default: false
            }
        }
        guard let sortIndex, let oldModel = filterModel[safe: sortIndex] else { return }
        filterModel[sortIndex] = FilterModel(
            type: oldModel.type,
            image: oldModel.image,
            text: oldModel.text,
            isSelected: FilterService.shared.sortingAuto.contains(where: { $0.isSelected })
        )
        collectionView.reloadData()
    }

    @objc
    private func filteredAutosUpdated() {
        let filtersIndex = filterModel.firstIndex {
            switch $0.type {
            case .filter:
                true
            default:
                false
            }
        }
        
        guard let filtersIndex,
              let oldModel = filterModel[safe: filtersIndex] else { return }
        filterModel[filtersIndex] = FilterModel(
            type: oldModel.type,
            image: oldModel.image,
            text: oldModel.text,
            isSelected: FilterService.shared.hasFilters
        )
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension FilterView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filterModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FilterCell = collectionView.dequeueCell(for: indexPath)
        cell.configure(with: filterModel[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FilterView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight = collectionView.bounds.height
        let imageWidth = cellHeight - .filterCellMargin
        var textWidth: CGFloat = .zero
        if let text = filterModel[indexPath.item].text {
            let size = (text as NSString).size(withAttributes: [.font: UIFont.openSans() ?? .systemFont(ofSize: 14)])
            textWidth = size.width + .filterCellMargin
        }
        var totalWidth = imageWidth + textWidth
        if filterModel[indexPath.item].isSelected {
            totalWidth += .filterCellMargin * 2 + CGSize.filterCellIconSize.width * 2
        }
        return CGSize(width: totalWidth, height: .emptyCellHeight - .filterCellMargin * 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: .zero, left: 12, bottom: .zero, right: 12)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filterItem = filterModel[indexPath.item]
        switch filterItem.type {
        case .filter:
            coordinator.openFilterViewController()
        case .date:
            coordinator.openCalendarViewController()
        case .autoType:
            coordinator.openBottomSheet(type: .autoType)
        case .sort:
            coordinator.openBottomSheet(type: .sorting)
        case .delete:
            print("+++ delete")
            ()
        }
    }
}
