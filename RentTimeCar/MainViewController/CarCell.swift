//
//  CarCell.swift
//  RentTimeCar
//
//  Created by Ekaterina Volobueva on 31.07.2025.
//
import PinLayout
import UIKit

final class CarCell: UICollectionViewCell {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .white
        label.font = UIFont.openSans()
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .white
        label.font = UIFont.openSans()
        return label
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.black.withAlphaComponent(0.6).cgColor,
            UIColor.clear.cgColor
        ]
        layer.locations = [0, 1]
        return layer
    }()
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        autoSizeThatFits(size, layoutClosure: performLayout)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        performLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = ""
        priceLabel.text = ""
    }

    func configure(model: Autos) {
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

private extension CarCell {
    
    func setupViews() {
        backgroundColor = .black
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
