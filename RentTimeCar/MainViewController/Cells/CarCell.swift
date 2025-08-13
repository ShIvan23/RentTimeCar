//
//  CarCell.swift
//  RentTimeCar
//
//  Created by Ekaterina Volobueva on 31.07.2025.
//

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

    private let titleLabel = Label()
    private let priceLabel = Label()
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.black.withAlphaComponent(0.6).cgColor,
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

        guard let urlString = model.files.first?.url,
              let url = URL(string: urlString)
        else {
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }.resume()
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
        gradientLayer.frame = imageView.bounds
        titleLabel.pin
            .top(30)
            .horizontally(10)
            .sizeToFit(.width)
        priceLabel.pin
            .below(of: titleLabel, aligned: .left)
            .marginTop(4)
            .horizontally(10)
            .sizeToFit(.width)
    }
}
