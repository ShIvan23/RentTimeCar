//
//  RentSummaryCollectionViewCell.swift
//  RentTimeCar
//
//  Created by Андрей Пермяков on 09.02.2026.
//

import UIKit

struct RentItem {
    let title: String
    let amount: Int
    let icon: UIImage?
}

final class RentSummaryCollectionViewCell: UICollectionViewCell {
    
    static let reuseId = "RentSummaryCollectionViewCell"
    
    private lazy var iconImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.isHidden = true
        return image
    }()
    
    private let titleLabel = Label(
        text: "",
        numberOfLines: 1,
        fontSize: 16,
        textColor: .secondaryTextColor,
        textAlignment: .left
        )
    
    private let valueLabel = Label(
        text: "",
        numberOfLines: 1,
        fontSize: 16,
        textColor: .whiteTextColor,
        textAlignment: .right
    )
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.isHidden = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        [iconImage, titleLabel, valueLabel, separatorView].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            iconImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImage.widthAnchor.constraint(equalToConstant: 16),
            iconImage.heightAnchor.constraint(equalToConstant: 16),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 50),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            separatorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func setSeparatorVisible(_ visible: Bool) {
        separatorView.isHidden = !visible
    }
    
    func configure(with item: RentItem) {
        titleLabel.text = item.title
        //если 0 то ничего не показываем, без цены формирование только заголовка
        valueLabel.text = item.amount > 0 ? "\(item.amount) ₽" : ""
        
        iconImage.image = item.icon?.withRenderingMode(.alwaysTemplate)
        iconImage.tintColor = item.icon == nil ? nil : .white
        iconImage.isHidden = item.icon == nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImage.image = nil
        iconImage.isHidden = true
        titleLabel.text = nil
        valueLabel.text = nil
    }
    
}

