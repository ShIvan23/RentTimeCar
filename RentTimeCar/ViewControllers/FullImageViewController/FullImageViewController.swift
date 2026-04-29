//
//  FullImageViewController.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 26.10.2025.
//

import PinLayout
import UIKit

final class FullImageViewController: UIViewController {

    // MARK: - Private Properties

    private let images: [String]
    private let initialIndex: Int
    private var currentIndex: Int
    private var hasScrolledToInitial = false

    // MARK: - UI

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .black
        cv.dataSource = self
        cv.delegate = self
        cv.register(cell: ImageGalleryCell.self)
        return cv
    }()

    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.numberOfPages = images.count
        pc.currentPage = initialIndex
        pc.currentPageIndicatorTintColor = .white
        pc.pageIndicatorTintColor = .white.withAlphaComponent(0.4)
        pc.isUserInteractionEnabled = false
        pc.hidesForSinglePage = true
        return pc
    }()

    private lazy var backButton: UIButton = {
        let btn = UIButton()
        btn.setImage(.redCross, for: .normal)
        btn.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        return btn
    }()

    private lazy var dismissPan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleDismissPan))
        pan.delegate = self
        return pan
    }()

    // MARK: - Init

    init(images: [String], initialIndex: Int = 0) {
        self.images = images
        self.initialIndex = initialIndex
        self.currentIndex = initialIndex
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubviews([collectionView, pageControl, backButton])
        view.addGestureRecognizer(dismissPan)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        performLayout()
        scrollToInitialIndexIfNeeded()
    }

    // MARK: - Private Methods

    private func performLayout() {
        collectionView.frame = view.bounds

        backButton.pin
            .top(view.layoutMargins.top)
            .right(15)
            .size(CGSize(square: 32))

        pageControl.pin
            .bottom(view.safeAreaInsets.bottom + 12)
            .hCenter()
            .sizeToFit()
    }

    private func scrollToInitialIndexIfNeeded() {
        guard !hasScrolledToInitial, collectionView.bounds.width > 0, !images.isEmpty else { return }
        hasScrolledToInitial = true
        let indexPath = IndexPath(item: initialIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }

    @objc private func backButtonAction() {
        dismiss(animated: true)
    }

    @objc private func handleDismissPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)

        switch gesture.state {
        case .changed:
            let dy = max(0, translation.y)
            view.transform = CGAffineTransform(translationX: 0, y: dy)
            view.alpha = max(0.4, 1 - dy / 400)
        case .ended, .cancelled:
            if translation.y > 120 || velocity.y > 700 {
                animateDismiss()
            } else {
                UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 1) {
                    self.view.transform = .identity
                    self.view.alpha = 1
                }
            }
        default:
            break
        }
    }

    private func animateDismiss() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
            self.view.alpha = 0
        }) { _ in
            self.dismiss(animated: false)
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension FullImageViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === dismissPan,
              let pan = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        let v = pan.velocity(in: view)
        return v.y > 0 && abs(v.y) > abs(v.x)
    }
}

// MARK: - UICollectionViewDataSource

extension FullImageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageGalleryCell = collectionView.dequeueCell(for: indexPath)
        cell.configure(with: images[indexPath.item])
        cell.imageScrollView.onDismissFlick = { [weak self] in
            self?.animateDismiss()
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FullImageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.bounds.size
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(round(collectionView.contentOffset.x / collectionView.bounds.width))
        guard page != currentIndex else { return }
        // Сбрасываем зум на предыдущей странице
        let prevIndexPath = IndexPath(item: currentIndex, section: 0)
        if let prevCell = collectionView.cellForItem(at: prevIndexPath) as? ImageGalleryCell {
            prevCell.imageScrollView.resetZoom()
        }
        currentIndex = page
        pageControl.currentPage = page
    }
}
