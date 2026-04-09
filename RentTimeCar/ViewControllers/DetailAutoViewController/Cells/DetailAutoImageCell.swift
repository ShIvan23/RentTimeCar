//
//  DetailAutoImageCell.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 15.10.2025.
//

import NukeExtensions
import PinLayout
import UIKit

final class DetailAutoImageCell: UICollectionViewCell {
    // MARK: - UI
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let numberImageLabel = Label(numberOfLines: 1 ,textAlignment: .left)
    
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
        numberImageLabel.text = ""
    }
    
    // MARK: - Internal Methods
    
    func configure(imageUrlString: String?, indexCell: Int, totalCellCount: Int) {
        numberImageLabel.text = "   \(indexCell) / \(totalCellCount)   "
        
        guard let imageUrlString,
              let url = URL(string: imageUrlString) else {
            assertionFailure("Invalid url")
            return
        }
        let options = ImageLoadingOptions(transition: .fadeIn(duration: 0.3))
        NukeExtensions.loadImage(with: url, options: options, into: imageView)
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        contentView.backgroundColor = .mainBackground
        contentView.addSubview(imageView)
        imageView.addSubview(numberImageLabel)
        numberImageLabel.backgroundColor = .black
        numberImageLabel.layer.cornerRadius = 6
        numberImageLabel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        numberImageLabel.clipsToBounds = true
    }
    
    private func performLayout() {
        imageView.pin.all()
        
        numberImageLabel.pin
            .bottomRight()
            .marginBottom(12)
            .sizeToFit()
    }
}
