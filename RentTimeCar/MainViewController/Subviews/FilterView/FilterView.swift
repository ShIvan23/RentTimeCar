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
    }
    
    private func performLayout() {
        collectionView.pin.all()
            .marginVertical(4)
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
        let totalWidth = imageWidth + textWidth
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
            ()
        case .autoType:
            ()
        case .sort:
            ()
        case .delete:
            ()
        }
    }
}
