//
//  CarCell.swift
//  RentTimeCar
//
//  Created by Ekaterina Volobueva on 31.07.2025.
//

import Nuke
import NukeExtensions
import NukeUI
import PinLayout
import UIKit

final class CarCell: UICollectionViewCell {
    // MARK: - UI
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let titleLabel = Label(numberOfLines: 1 ,textAlignment: .left)
    private let priceLabel = Label(numberOfLines: 1, textAlignment: .left)
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.black.withAlphaComponent(0.8).cgColor,
            UIColor.clear.cgColor
        ]
        layer.locations = [0, 1]
        return layer
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
    
    // MARK: - Override
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = ""
        priceLabel.text = ""
    }

    // MARK: - Internal Methods
    
    func configure(model: Auto) {
        titleLabel.text = model.title
        priceLabel.text = "\(model.defaultPriceWithDiscountSt) ₽/сутки"

        guard let urlString = model.files.first(where: { $0.url != nil && $0.folder == .folderImageValue })?.url,
              let url = URL(string: urlString)
        else {
            return
        }
        
        let options = ImageLoadingOptions(placeholder: .carPlaceholder, transition: .fadeIn(duration: 0.3))
        NukeExtensions.loadImage(with: url, options: options, into: imageView)
    }
}

// MARK: - Private Methods

private extension CarCell {
    func setupView() {
        contentView.backgroundColor = .mainBackground
        contentView.addSubview(imageView)
        imageView.layer.addSublayer(gradientLayer)
        imageView.addSubviews([titleLabel, priceLabel])
     }

    func performLayout() {
        imageView.pin.all()
        
        gradientLayer.pin
            .top()
            .horizontally()
            .height(bounds.height * 0.2)
        
        titleLabel.pin
            .top(4)
            .horizontally(10)
            .sizeToFit(.width)
        
        priceLabel.pin
            .below(of: titleLabel, aligned: .left)
            .marginTop(4)
            .horizontally(10)
            .sizeToFit(.width)
    }
}
