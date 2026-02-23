//
//  DoubleSliderView.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 15.08.2025.
//

import PinLayout
import SnapKit
import UIKit

protocol DoubledSliderDelegate: AnyObject {
    func minValueDidChange(_ value: Int)
    func maxValueDidChange(_ value: Int)
}

protocol DoubledSliderEndDraggingDelegate: AnyObject {
    func didEndDragging(minimumValueNow: Int, maximumValueNow: Int)
}

final class DoubledSlider: UIView {
    
    // MARK: - UI
    
    private let track = UIView()
    private let activeTrack = UIView()
    private let leftThumb = UIView()
    private let rightThumb = UIView()
    
    // MARK: - Internal Properties
    
    weak var delegate: DoubledSliderDelegate?
    weak var endDraggingDelegate: DoubledSliderEndDraggingDelegate?

    // MARK: - Private Properties
    
    private var minimumValue: CGFloat = .zero
    private var maximumValue: CGFloat = .zero
    private var minimumValueNow: CGFloat = .zero
    private var maximumValueNow: CGFloat = .zero
    
    private var leftThumbOffset: CGFloat = .defaultThumbOffset
    private var rightThumbOffset: CGFloat = 0
    private var isInitRightThumbOffset = true
    // флаги, которые прикрывают баги неточного выставления offset, после ввода значения в texField
    private var needUpdateMinValue = true
    private var needUpdateMaxValue = true
    
    // Здесь записываются initial offsets для leftThumb и rightThumb. Нужна для расчета при введении значения через textField
    private var offsetsForCalculation: (min: CGFloat, max: CGFloat) = (.defaultThumbOffset, .zero)
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        performLayout()
        updateMinAndMaxValue()
    }
    
    // MARK: - Internal Methods
    
    func configure(with model: FilterValueModel) {
        minimumValue = CGFloat(model.minValue)
        maximumValue = CGFloat(model.maxValue)
        minimumValueNow = CGFloat(model.minValueNow)
        maximumValueNow = CGFloat(model.maxValueNow)
        setMinValue(model.minValueNow)
        setMaxValue(model.maxValueNow)
        setNeedsLayout()
    }
    
    func setMinValue(_ value: Int) {
        let newValue = CGFloat(value)
        guard newValue >= minimumValue && newValue <= maximumValue else {
            leftThumbOffset = offsetsForCalculation.min
            setNeedsLayout()
            return
        }
        minimumValueNow = newValue
        let difference = maximumValue - minimumValue
        let valueInOnePoint = difference / (offsetsForCalculation.max - offsetsForCalculation.min)
        let needPointsToOffset = (newValue - minimumValue) / valueInOnePoint
        leftThumbOffset = needPointsToOffset + .defaultThumbOffset
        needUpdateMinValue = false

        setNeedsLayout()
    }
    
    func setMaxValue(_ value: Int) {
        let newValue = CGFloat(value)
        guard newValue >= minimumValue && newValue <= maximumValue else {
            rightThumbOffset = offsetsForCalculation.max
            setNeedsLayout()
            return
        }
        maximumValueNow = newValue
        let difference = maximumValue - minimumValue
        let valueInOnePoint = difference / (offsetsForCalculation.max - offsetsForCalculation.min)
        let needPointsToOffset = (maximumValue - newValue) / valueInOnePoint
        let total = offsetsForCalculation.max - needPointsToOffset
        rightThumbOffset = total
        needUpdateMaxValue = false
        setNeedsLayout()
    }
    
    // MARK: - Private Methods
    
    private func performLayout() {
        if bounds != .zero,
           isInitRightThumbOffset {
            isInitRightThumbOffset = false
            rightThumbOffset = bounds.width - .defaultThumbOffset * 2
            offsetsForCalculation.max = rightThumbOffset
        }
        track.pin
            .horizontally()
            .vCenter()
            .marginHorizontal(.defaultThumbOffset + .thumbWidth / 2)
            .height(2)
        
        leftThumb.pin
            .left()
            .vCenter()
            .marginLeft(leftThumbOffset)
            .size(CGSize(square: .thumbWidth))
        
        rightThumb.pin
            .left()
            .vCenter()
            .marginLeft(rightThumbOffset)
            .size(CGSize(square: .thumbWidth))
        
        activeTrack.pin
            .left(to: leftThumb.edge.right)
            .right(to: rightThumb.edge.left)
            .vCenter()
            .height(3)
    }
    
    private func updateMinAndMaxValue() {
        if needUpdateMinValue {
            updateLeftThumb()
        }
        if needUpdateMaxValue {
            updateRightThumb()
        }
    }
    
    private func updateLeftThumb() {
        let leftThumbX = leftThumb.frame.midX
        let leftThumbDistancePassed = abs(track.frame.minX - leftThumbX)
        let totalDistance = track.frame.width
        let distancePassedFraction = leftThumbDistancePassed / totalDistance
        let valueDifference = maximumValue - minimumValue
        let currentValue = minimumValue + distancePassedFraction * valueDifference
        guard !(currentValue.isNaN || currentValue.isInfinite) else { return }
        delegate?.minValueDidChange(Int(currentValue))
    }
    
    private func updateRightThumb() {
        let rightThumbX = rightThumb.frame.midX
        let rightThumbDistancePassed = abs(track.frame.maxX - rightThumbX)
        let totalDistance = track.frame.width
        let distancePassedFraction = rightThumbDistancePassed / totalDistance
        let valueDifference = maximumValue - minimumValue
        let currentValue = distancePassedFraction * valueDifference
        guard !(currentValue.isNaN || currentValue.isInfinite) else { return }
        delegate?.maxValueDidChange(Int(maximumValue - currentValue))
    }
    
    private func setupView() {
        addSubviews([track, activeTrack, leftThumb, rightThumb])
        activeTrack.backgroundColor = .whiteTextColor
        track.backgroundColor = .secondaryTextColor
        [leftThumb, rightThumb].forEach {
            $0.backgroundColor = .whiteTextColor
            $0.layer.cornerRadius = 10
            $0.isUserInteractionEnabled = true
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panAction))
            $0.addGestureRecognizer(panGesture)
        }
        leftThumb.tag = 1
        rightThumb.tag = 2
    }
    
    @objc
    private func panAction(gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: self)
            handleDragging(view, withTranslation: translation)
            gesture.setTranslation(.zero, in: view)
        case .ended:
            endDraggingDelegate?.didEndDragging(
                minimumValueNow: Int(minimumValueNow),
                maximumValueNow: Int(maximumValueNow)
            )
        default:
            break
        }
    }
    
    private func handleDragging(_ view: UIView, withTranslation: CGPoint) {
        switch view.tag {
        case 1:
            if (leftThumb.frame.maxX + withTranslation.x) > rightThumb.frame.minX {
                leftThumbOffset = rightThumb.frame.minX - .defaultThumbOffset
            } else if (leftThumbOffset + withTranslation.x) < .defaultThumbOffset {
                leftThumbOffset = .defaultThumbOffset
            } else {
                leftThumbOffset += withTranslation.x
            }
            needUpdateMinValue = true
        case 2:
            if (rightThumb.frame.minX + withTranslation.x) < leftThumb.frame.maxX {
                rightThumbOffset = leftThumb.frame.maxX
            } else if (rightThumbOffset + withTranslation.x + rightThumb.frame.width) > track.frame.maxX + .thumbWidth / 2 {
                rightThumbOffset = track.frame.maxX - rightThumb.frame.width + .thumbWidth / 2
            } else {
                rightThumbOffset += withTranslation.x
            }
            needUpdateMaxValue = true
        default:
            break
        }
        setNeedsLayout()
    }
}

private extension CGFloat {
    static let defaultThumbOffset: CGFloat = 20
    static let thumbWidth: CGFloat = 20
}
