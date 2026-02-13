//
//  RentSeparatorCollectionViewCell.swift
//  RentTimeCar
//
//  Created by Андрей Пермяков on 13.02.2026.
//

import UIKit
import PinLayout

final class RentSeparatorCollectionViewCell: UICollectionViewCell {
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(separatorView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
 
    private func layout () {
        separatorView.pin
            .horizontally(32)
            .vCenter()
            .height(1)
    }
}
