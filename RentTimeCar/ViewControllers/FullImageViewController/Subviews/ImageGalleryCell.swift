//
//  ImageGalleryCell.swift
//  RentTimeCar
//

import UIKit

final class ImageGalleryCell: UICollectionViewCell {

    private(set) lazy var imageScrollView = ImageScrollView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageScrollView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageScrollView.frame = contentView.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageScrollView.resetZoom()
    }

    func configure(with urlString: String) {
        imageScrollView.set(image: urlString)
    }
}
