//
//  RentSeparatorCollectionViewCell.swift
//  RentTimeCar
//
//  Created by Андрей Пермяков on 13.02.2026.
//

import UIKit
import PinLayout

final class RentSeparatorCollectionViewCell: UICollectionViewCell {

    // MARK: - Public Properties
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        return view
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(separatorView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override Methods
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutSeparator()
    }

    // MARK: - Private Methods
    private func layoutSeparator() {
        separatorView.pin
            .horizontally(32)
            .vCenter()
            .height(1)
    }
}
