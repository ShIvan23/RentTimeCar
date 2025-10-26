//
//  DiscountView.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 16.10.2025.
//

import PinLayout
import UIKit

enum DiscountDays: Int, CaseIterable {
    case days5 = 5
    case days10 = 10
    case days20 = 20
    case days30 = 30
}

// Вьюшка, которая используется на деталке под фото для карусели со скидками
final class DiscountView: UIView {
    // MARK: - Private Properties
    
    private let model = DiscountDays.allCases
    private let priceByDay: Int
    
    // MARK: - UI
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .mainBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cell: DiscountCell.self)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    // MARK: Init
    
    init(priceByDay: Int) {
        self.priceByDay = priceByDay
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
    
    private func setupView() {
        addSubview(collectionView)
        collectionView.backgroundColor = .secondaryBackground
        collectionView.reloadData()
    }
    
    private func performLayout() {
        collectionView.pin.all()
    }
}

// MARK: - UICollectionViewDataSource

extension DiscountView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        model.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: DiscountCell = collectionView.dequeueCell(for: indexPath)
        cell.configure(daysCount: model[indexPath.item].rawValue, priceByDay: priceByDay)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension DiscountView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.size.width
        let availableWidth = width - .collectionViewHorizontalInset * 2
        let visibleCellsCount = 2.2
        let itemWidth = (availableWidth / visibleCellsCount).rounded(.up)
        return CGSize(width: itemWidth,
                      height: collectionView.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        .collectionViewItemsSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(horizontal: .collectionViewHorizontalInset)
    }
}

private extension CGFloat {
    static let collectionViewHorizontalInset: CGFloat = 16
    static let collectionViewItemsSpacing: CGFloat = 6
}
