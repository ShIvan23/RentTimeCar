//
//  FinePhotosViewController.swift
//  RentTimeCar
//

import Nuke
import NukeExtensions
import PinLayout
import UIKit

final class FinePhotosViewController: UIViewController {

    // MARK: - Private Properties

    private let images: [String]
    private let coordinator: ICoordinator

    // MARK: - UI

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .mainBackground
        cv.dataSource = self
        cv.delegate = self
        cv.register(cell: PhotoThumbnailCell.self)
        return cv
    }()

    // MARK: - Init

    init(images: [String], coordinator: ICoordinator) {
        self.images = images
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Фото нарушения"
        view.backgroundColor = .mainBackground
        navigationController?.isNavigationBarHidden = false
        view.addSubview(collectionView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.pin.all(view.pin.safeArea)
    }
}

// MARK: - UICollectionViewDataSource

extension FinePhotosViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PhotoThumbnailCell = collectionView.dequeueCell(for: indexPath)
        cell.configure(with: images[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FinePhotosViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        coordinator.openFullImageViewController(images: images, initialIndex: indexPath.item)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.bounds.width - 32
        return CGSize(width: width, height: width * 9 / 16)
    }
}

// MARK: - PhotoThumbnailCell

private final class PhotoThumbnailCell: UICollectionViewCell {

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .secondaryBackground
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        contentView.addSubview(imageView)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.pin.all()
    }

    func configure(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        NukeExtensions.loadImage(with: url, options: ImageLoadingOptions(transition: .fadeIn(duration: 0.2)), into: imageView)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
