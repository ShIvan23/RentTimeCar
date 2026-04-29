//
//  ImageScrollView.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 26.10.2025.
//

import NukeExtensions
import UIKit

final class ImageScrollView: UIScrollView, UIScrollViewDelegate {

    // Вызывается когда пользователь отрывает палец у дна зумированного фото с velocity вниз
    var onDismissFlick: (() -> Void)?

    private let imageZoomView = UIImageView()
    
    private lazy var zoomingTap: UITapGestureRecognizer = {
        let zoomingTap = UITapGestureRecognizer(target: self, action: #selector(handleZoomingTap))
        zoomingTap.numberOfTapsRequired = 2
        return zoomingTap
    }()
    
    init() {
        super.init(frame: .zero)
        
        delegate = self
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        decelerationRate = UIScrollView.DecelerationRate.fast
        imageZoomView.contentMode = .scaleAspectFit
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetZoom() {
        setZoomScale(minimumZoomScale, animated: false)
    }

    func set(image: String) {
        addSubview(imageZoomView)
        let imageUrl = URL(string: image)
        NukeExtensions.loadImage(with: imageUrl, into: imageZoomView) { [weak self] result in
            switch result {
            case .success(let response):
                self?.configurateFor(imageSize: response.image.size)
                self?.setNeedsLayout()
            case .failure:
                break
            }
        }
    }
    
    private func configurateFor(imageSize: CGSize) {
        contentSize = imageSize
        zoomScale = minimumZoomScale
        
        imageZoomView.addGestureRecognizer(zoomingTap)
        imageZoomView.isUserInteractionEnabled = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        performLayout()
        centerImage()
        setCurrentMaxandMinZoomScale()
    }
    
    private func setCurrentMaxandMinZoomScale() {
        let boundsSize = bounds.size
        let imageSize = imageZoomView.bounds.size
        
        let xScale = boundsSize.width / imageSize.width
        let yScale = boundsSize.height / imageSize.height
        let minScale = min(xScale, yScale)
        
        minimumZoomScale = minScale
        maximumZoomScale = 3.0
    }
    
    private func performLayout() {
        imageZoomView.pin
            .horizontally()
            .vCenter()
            .height(bounds.width)
    }
    
    private func centerImage() {
        let boundsSize = bounds.size
        var frameToCenter = imageZoomView.frame
        
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }
        
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }
        
        imageZoomView.frame = frameToCenter
    }
    
    // gesture
    @objc func handleZoomingTap(sender: UITapGestureRecognizer) {
        let location = sender.location(in: sender.view)
        zoom(point: location, animated: true)
    }
    
    private func zoom(point: CGPoint, animated: Bool) {
        let currectScale = zoomScale
        let minScale = minimumZoomScale
        let maxScale = maximumZoomScale
        
        if (minScale == maxScale && minScale > 1) {
            return
        }
        
        let toScale = maxScale
        let finalScale = (currectScale == minScale) ? toScale : minScale
        let zoomRect = zoomRect(scale: finalScale, center: point)
        self.zoom(to: zoomRect, animated: animated)
    }
    
    private func zoomRect(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        let bounds = bounds
        
        zoomRect.size.width = bounds.size.width / scale
        zoomRect.size.height = bounds.size.height / scale
        
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2)
        return zoomRect
    }
    
    // MARK: - Gesture

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == panGestureRecognizer,
              let pan = gestureRecognizer as? UIPanGestureRecognizer else {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
        let velocity = pan.velocity(in: self)

        // Вертикальный свайп вниз: уступаем родителю для dismiss
        if velocity.y > 0 && abs(velocity.y) > abs(velocity.x) {
            let isAtMinZoom = zoomScale <= minimumZoomScale + 0.01
            if isAtMinZoom {
                return false  // не зумировано → dismiss
            }
            let contentOverflows = contentSize.height > bounds.height + 1
            let atBottom = contentOffset.y >= contentSize.height - bounds.height - 1
            if !contentOverflows || atBottom {
                return false  // достигли низа зумированного контента → dismiss
            }
            // Сильно зумировано, не внизу: быстрый флик всё равно уходит на dismiss
            if velocity.y > 800 {
                return false
            }
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }

        // Горизонтальный свайп — не трогаем вертикальное
        guard abs(velocity.x) > abs(velocity.y) else {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
        // При минимальном масштабе горизонтальный свайп уходит во внешний UICollectionView
        if zoomScale <= minimumZoomScale + 0.01 {
            return false
        }
        // При зуме проверяем горизонтальный край
        let atLeftEdge  = contentOffset.x <= 0 && velocity.x > 0
        let atRightEdge = contentOffset.x >= contentSize.width - bounds.width - 1 && velocity.x < 0
        if atLeftEdge || atRightEdge { return false }

        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }

    // MARK: - UIScrollViewDelegate

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageZoomView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // Непрерывный жест долистал до дна → триггерим dismiss
        let vel = panGestureRecognizer.velocity(in: self).y
        guard vel > 500 else { return }
        let maxOffsetY = max(0, contentSize.height - bounds.height)
        guard contentOffset.y >= maxOffsetY - 2 else { return }
        onDismissFlick?()
    }
}
