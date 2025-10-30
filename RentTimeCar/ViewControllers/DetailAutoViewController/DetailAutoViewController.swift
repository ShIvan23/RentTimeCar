//
//  DetailAutoViewController.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 15.10.2025.
//

import Nuke
import PinLayout
import UIKit

final class DetailAutoViewController: UIViewController {
    // MARK: - Private Properties
    
    private let autoModel: Auto
    private lazy var imagePrefetcher = ImagePrefetcher(pipeline: ImagePipeline.shared)
    private var indexOfCellBeforeDragging = 0
    private let coordinator: ICoordinator
    
    // MARK: - UI
    
    private lazy var imagesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .mainBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.register(cell: DetailAutoImageCell.self)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let stackView = ManualLayoutBasedStackView()
    
    private lazy var detailStackViews = [
        DetailStackView(image: .filter, text: "\(autoModel.motorPower) л.с."),
        DetailStackView(image: .calendar, text: "\(autoModel.mileageLimit) км/ч"),
        DetailStackView(image: .car2, text: autoModel.fuelType)
    ]
    
    private lazy var discountView = DiscountView(priceByDay: autoModel.defaultPriceWithDiscountSt)
    private let insuranceView = InsuranceView()
    
    private let selectedDateView = SelectDateView()
    
    // MARK: - Init
    
    init(
        autoModel: Auto,
        coordinator: ICoordinator
    ) {
        let filteredPhotos = autoModel.files.filter { $0.folder == .folderImageValue }
        let currentModel = Auto(
            title: autoModel.title,
            files: filteredPhotos,
            defaultPriceWithDiscountSt: autoModel.defaultPriceWithDiscountSt,
            marka: autoModel.marka,
            motorPower: autoModel.motorPower,
            classAuto: autoModel.classAuto,
            mileageLimit: autoModel.mileageLimit,
            fuelType: autoModel.fuelType
        )
        self.autoModel = currentModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        performLayout()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        view.backgroundColor = .mainBackground
        view.addSubviews([imagesCollectionView, stackView, discountView, insuranceView, selectedDateView])
        navigationController?.isNavigationBarHidden = false
        configureStackView()
        selectedDateView.addTapGestureClosure { [weak self] in
            self?.coordinator.openCalendarViewController()
        }
    }
    
    private func performLayout() {
        imagesCollectionView.pin
            .top()
            .horizontally()
            .marginTop(view.layoutMargins.top)
            .height(view.bounds.width * 0.75)
        
        stackView.pin
            .below(of: imagesCollectionView)
            .horizontally()
            .height(.stackViewHeight)
        
        updateSizeItemsInStackView()
        
        discountView.pin
            .below(of: stackView)
            .horizontally()
            .height(80)
        
        insuranceView.pin
            .below(of: discountView)
            .horizontally()
            .height(44)
        
        selectedDateView.pin
            .below(of: insuranceView)
            .marginTop(20)
            .horizontally()
            .marginHorizontal(.stackViewHorizontalInset)
            .sizeToFit(.width)
    }
    
    private func configureStackView() {
        stackView.backgroundColor = .secondaryBackground
        stackView.axis = .horizontal
        stackView.spacing = .stackViewSpacing
        stackView.contentInsets = UIEdgeInsets(top: .zero, left: .stackViewHorizontalInset, bottom: .zero, right: .stackViewHorizontalInset)
        detailStackViews.forEach {
            stackView.addArrangedSubview($0)
        }
    }
    
    private func updateSizeItemsInStackView() {
        let width = view.bounds.width
        let horizontalContentInsets: CGFloat = .stackViewHorizontalInset * 2
        let viewsCount = detailStackViews.count
        let spacingBetweenItems: CGFloat = .stackViewSpacing * (CGFloat(viewsCount) - 1)
        let availableWidth = width - horizontalContentInsets - spacingBetweenItems
        let itemWidth = availableWidth / CGFloat(viewsCount)
        detailStackViews.forEach {
            stackView.setCustomSize(CGSize(width: itemWidth, height: .stackViewHeight), for: $0)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension DetailAutoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        autoModel.files.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: DetailAutoImageCell = collectionView.dequeueCell(for: indexPath)
        cell.configure(
            imageUrlString: autoModel.files[safe: indexPath.item]?.url,
            indexCell: indexPath.item + 1,
            totalCellCount: autoModel.files.count
        )
        return cell
    }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension DetailAutoViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urlsForPrefetch: [URL] = indexPaths.compactMap {
            guard let urlString = autoModel.files[safe: $0.item]?.url,
                  let url = URL(string: urlString) else { return nil }
            return url
        }
        imagePrefetcher.startPrefetching(with: urlsForPrefetch)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension DetailAutoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        .zero
    }
    
    /// Для плавного перелистывания фотографий
    ///  https://stackoverflow.com/questions/22895465/paging-uicollectionview-by-cells-not-screen
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let pageWidth = imagesCollectionView.bounds.width
        let proportionalOffset = imagesCollectionView.contentOffset.x / pageWidth
        indexOfCellBeforeDragging = Int(round(proportionalOffset))
    }
    
    /// Для плавного перелистывания фотографий
    /// https://stackoverflow.com/questions/22895465/paging-uicollectionview-by-cells-not-screen
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee = scrollView.contentOffset
        
        // Calculate conditions
        let pageWidth = imagesCollectionView.bounds.width
        let collectionViewItemCount = autoModel.files.count
        let proportionalOffset = imagesCollectionView.contentOffset.x / pageWidth
        let indexOfMajorCell = Int(round(proportionalOffset))
        let swipeVelocityThreshold: CGFloat = 0.5
        let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < collectionViewItemCount && velocity.x > swipeVelocityThreshold
        let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
        let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
        let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)
        
        if didUseSwipeToSkipCell {
            let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
            let toValue = pageWidth * CGFloat(snapToIndex)
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: velocity.x,
                options: .allowUserInteraction,
                animations: {
                    scrollView.contentOffset = CGPoint(x: toValue, y: 0)
                    scrollView.layoutIfNeeded()
                },
                completion: nil
            )
        } else {
            let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
            imagesCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let autoImage = autoModel.files[safe: indexPath.item]?.url else { return }
        coordinator.openFullImageViewController(with: autoImage)
    }
}

private extension CGFloat {
    static let stackViewHorizontalInset: CGFloat = 16
    static let stackViewSpacing: CGFloat = 10
    static let stackViewHeight: CGFloat = 60
}
