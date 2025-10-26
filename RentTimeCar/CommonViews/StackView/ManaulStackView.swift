//
//  ManaulStackView.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 15.10.2025.
//

import UIKit

public extension ManualLayoutBasedStackView {
    enum Axis {
        case vertical
        case horizontal
    }

    enum Alignment {
        case fill
        case leading
        case trailing
        case top
        case bottom
        case center
    }
}

/// A streamlined interface for laying out a collection of views in either a column or a row.
///
/// Laytou based on view's sizeThatFits(_ size: CGSize) method.
open class ManualLayoutBasedStackView: UIView {
    // MARK: - Properties: Public

    /// The axis along which the arranged views are laid out.
    ///
    /// The default value is ManualLayoutBasedStackView.Axis.vertical.
    public var axis: Axis = .vertical {
        didSet {
            if oldValue != axis {
                setNeedsLayout()
            }
        }
    }

    /// The alignment of the arranged subviews perpendicular to the stack view’s axis.
    ///
    /// The default value is ManualLayoutBasedStackView.Alignment.fill.
    public var alignment: Alignment = .fill {
        didSet {
            if oldValue != alignment {
                setNeedsLayout()
            }
        }
    }

    /// The distance in points between the adjacent edges of the stack view’s arranged views.
    ///
    /// The default value is 0.
    public var spacing: CGFloat = 0 {
        didSet {
            if oldValue != spacing {
                setNeedsLayout()
            }
        }
    }

    /// Content insets from edges of stack view
    ///
    /// The default value is `UIEdgeInsets.zero`
    public var contentInsets: UIEdgeInsets = .zero {
        didSet {
            if oldValue != contentInsets {
                setNeedsLayout()
            }
        }
    }

    /// The limit of element stretch in the direction of scrolling.
    /// The priority of this property is below than `customSize`.
    /// The default value is `nil`
    public var scrollableDimensionStretchLimit: CGFloat? {
        didSet {
            if oldValue != scrollableDimensionStretchLimit {
                setNeedsLayout()
            }
        }
    }

    /// The list of views arranged by the stack view.
    public var arrangedSubviews: [UIView] {
        return _arrangedSubviewInfos.map({ $0.view })
    }

    public static var shouldUseNewLayout: Bool = false

    private var _arrangedSubviewInfos: [ArrangedSubviewInfo] = []
    private let _indexesHelper: NSMutableOrderedSet = .init()

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        assertionFailure()
    }

    // MARK: - Public

    /// Adds a view to the end of the arrangedSubviews array.
    /// - Parameter view: The view to be added to the array of views arranged by the stack.
    ///
    /// The stack view ensures that the arrangedSubviews array is always a subset of its subviews array.
    /// This method automatically adds the provided view as a subview of the stack view, if it is not already.
    /// If the view is already a subview, this operation does not alter the subview ordering.
    public func addArrangedSubview(_ view: UIView) {
        removeIfExist(view: view)
        _arrangedSubviewInfos.append(.init(view: view))
        _indexesHelper.add(view)

        if view.superview != self {
            addSubview(view)
        }
        setNeedsLayout()
    }

    /// Adds the provided view to the array of arranged subviews at the specified index.
    /// - Parameters:
    ///   - view: The view to be added to the array of views arranged by the stack.
    ///   - index: The index where the stack inserts the new view in its arrangedSubviews array. This value must not be greater than the number of views currently in this array
    ///
    /// If index is already occupied, the stack view increases the size of the arrangedSubviews array and shifts all of its contents at the index and above to the next higher space in the array.
    /// Then the stack view stores the provided view at the index.
    ///
    /// The stack view also ensures that the arrangedSubviews array is always a subset of its subviews array.
    /// This method automatically adds the provided view as a subview of the stack view, if it is not already.
    /// When adding subviews, the stack view appends the view to the end of its subviews array.
    /// The index only affects the order of views in the arrangedSubviews array. It does not affect the ordering of views in the subviews array.
    public func insertArrangedSubview(_ view: UIView, at index: Int) {
        removeIfExist(view: view)
        _arrangedSubviewInfos.insert(.init(view: view), at: index)
        _indexesHelper.insert(view, at: index)
        if view.superview != self {
            addSubview(view)
        }
        setNeedsLayout()
    }

    /// Removes the provided view from the stack’s array of arranged subviews.
    /// - Parameter view: The view to be removed from the array of views arranged by the stack.
    ///
    /// This method removes the provided view from the stack’s arrangedSubviews array.
    /// The view’s position and size will no longer be managed by the stack view.
    /// However, this method does not remove the provided view from the stack’s subviews array;
    /// therefore, the view is still displayed as part of the view hierarchy.
    ///
    /// To prevent the view from appearing on screen after calling the stack’s removeArrangedSubview:
    ///  method, explicitly remove the view from the subviews array by calling the view’s removeFromSuperview() method,
    ///  or set the view’s isHidden property to true.
    public func removeArrangedSubview(_ view: UIView) {
        removeIfExist(view: view)
        setNeedsLayout()
    }

    /// Removes the provided view from the stack’s array of arranged subviews.
    /// - Parameter view: The view to be removed from the array of views arranged by the stack.
    ///
    /// This method removes all views from arrangedSubviews array.
    /// The view’s positions and sizes will no longer be managed by the stack view.
    /// However, this method does not remove the arrangedSubviews from the stack’s subviews array;
    /// therefore, the view is still displayed as part of the view hierarchy.
    ///
    /// To prevent the views from appearing on screen after calling the stack’s removeArrangedSubview:
    ///  method, explicitly remove the view from the subviews array by calling the view’s removeFromSuperview() method,
    ///  or set the view’s isHidden property to true.
    public func removeAllArrangedSubviews() {
        _arrangedSubviewInfos.removeAll()
        _indexesHelper.removeAllObjects()
        setNeedsLayout()
    }

    /// Applies custom spacing after the specified view.
    /// - Parameters:
    ///   - spacing: Spacing.
    ///   - view: The view from arrangedSubviews array.
    public func setCustomSpacing(_ spacing: CGFloat, after view: UIView) {
        let index = _indexesHelper.index(of: view)
        guard index != NSNotFound else { return }
        _arrangedSubviewInfos[index].customSpacing = spacing
    }

    /// Applies custom size for the specified view.
    /// - Parameters:
    ///   - size: Size.
    ///   - view: The view from arrangedSubviews array.
    public func setCustomSize(_ size: CGSize, for view: UIView) {
        let index = _indexesHelper.index(of: view)
        guard index != NSNotFound else { return }
        _arrangedSubviewInfos[index].customSize = size
    }

    /// Applies custom alignment for the specified view.
    /// - Parameters:
    ///   - alignment: Alignment.
    ///   - view: The view from arrangedSubviews array.
    public func setCustomAlignment(_ alignment: Alignment, for view: UIView) {
        let index = _indexesHelper.index(of: view)
        guard index != NSNotFound else { return }
        _arrangedSubviewInfos[index].customAlignment = alignment
    }

    // MARK: - lifecycle

    public override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        removeIfExist(view: subview)
        setNeedsLayout()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        switch axis {
        case .vertical:
            layoutVertical()
        case .horizontal:
            layoutHorizontal()
        }
    }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        let infos = _arrangedSubviewInfos.compactMap({ $0.view.isHidden ? nil : $0 })
        let spacingLength: CGFloat = infos.dropLast().reduce(into: 0, { $0 += $1.customSpacing ?? self.spacing })
        switch axis {
        case .vertical:
            var height: CGFloat = 0
            var maxWidth: CGFloat = 0
            let availableSize = CGSize(width: size.width - contentInsets.horizontal, height: .greatestFiniteMagnitude)
            for info in infos {
                var sizeThatFits = info.view.sizeThatFits(availableSize)
                if Self.shouldUseNewLayout {
                    sizeThatFits.height = min(sizeThatFits.height.ceilToDisplayScale(), scrollableDimensionStretchLimit ?? .greatestFiniteMagnitude)
                } else {
                    sizeThatFits.height = min(sizeThatFits.height, scrollableDimensionStretchLimit ?? .greatestFiniteMagnitude)
                }

                let size = info.customSize ?? sizeThatFits
                if Self.shouldUseNewLayout {
                    height = (height + size.height).roundToDisplayScale()
                } else {
                    height += size.height
                }

                maxWidth = max(maxWidth, size.width)
            }
            return CGSize(width: maxWidth + contentInsets.horizontal, height: height + spacingLength + contentInsets.vertical)
        case .horizontal:
            var width: CGFloat = 0
            var maxHeight: CGFloat = 0
            let availableSize = CGSize(width: .greatestFiniteMagnitude, height: size.height - contentInsets.vertical)
            for info in infos {
                var sizeThatFits = info.view.sizeThatFits(availableSize)
                if Self.shouldUseNewLayout {
                    sizeThatFits.width = min(sizeThatFits.width.ceilToDisplayScale(), scrollableDimensionStretchLimit ?? .greatestFiniteMagnitude)
                } else {
                    sizeThatFits.width = min(sizeThatFits.width, scrollableDimensionStretchLimit ?? .greatestFiniteMagnitude)
                }

                let subviewSize = info.customSize ?? sizeThatFits
                if Self.shouldUseNewLayout {
                    width = (width + subviewSize.width).roundToDisplayScale()
                } else {
                    width += subviewSize.width
                }

                maxHeight = max(maxHeight, subviewSize.height)
            }
            return CGSize(width: width + spacingLength + contentInsets.horizontal, height: maxHeight + contentInsets.vertical)
        }
    }

    // MARK: - Private

    private func layoutVertical() {
        var maxY: CGFloat = contentInsets.top
        let minX: CGFloat = contentInsets.left
        var contentHeight = contentInsets.vertical

        for info in _arrangedSubviewInfos where !info.view.isHidden {
            let view = info.view
            let alignment = info.customAlignment ?? self.alignment
            let availableHeight = max(0, bounds.height - (Self.shouldUseNewLayout ? contentHeight : contentInsets.vertical))
            let availableSize = CGSize(width: bounds.width - contentInsets.horizontal, height: availableHeight)
            var sizeThatFits = view.sizeThatFits(availableSize)
            let sizeThatFitsHeightCeiled = sizeThatFits.height.ceilToDisplayScale()
            contentHeight = (contentHeight + sizeThatFitsHeightCeiled).roundToDisplayScale()
            sizeThatFits.height = min(Self.shouldUseNewLayout ? sizeThatFitsHeightCeiled : sizeThatFits.height, scrollableDimensionStretchLimit ?? .greatestFiniteMagnitude)
            let size = info.customSize ?? sizeThatFits
            switch alignment {
            case .center:
                view.frame = CGRect(midX: bounds.midX, minY: maxY, size: size)
            case .leading:
                let minWidth = min(bounds.width, size.width)
                view.frame = CGRect(minX: minX, minY: maxY, size: .init(width: minWidth,
                                                                        height: size.height))
            case .trailing:
                let minWidth = min(bounds.width, size.width)
                view.frame = CGRect(maxX: bounds.maxX + minX, minY: maxY, size: .init(width: minWidth,
                                                                                      height: size.height))
            // layout illegal alignment same as fill
            case .fill,
                 .bottom,
                 .top:
                view.frame = CGRect(x: minX, y: maxY, width: bounds.width, height: size.height)
            }
            let spacing = info.customSpacing ?? self.spacing
            maxY = view.frame.maxY + spacing
        }
    }

    private func layoutHorizontal() {
        var maxX: CGFloat = contentInsets.left
        let minY: CGFloat = contentInsets.top
        var contentWidth = contentInsets.horizontal

        for info in _arrangedSubviewInfos where !info.view.isHidden {
            let view = info.view
            let alignment = info.customAlignment ?? self.alignment
            let availableWidth = max(0, bounds.width - (Self.shouldUseNewLayout ? contentWidth : contentInsets.horizontal))
            let availableSize = CGSize(width: availableWidth, height: bounds.height - contentInsets.vertical)
            var sizeThatFits = view.sizeThatFits(availableSize)
            let sizeThatFitsWidthCeiled = sizeThatFits.width.ceilToDisplayScale()
            contentWidth = (contentWidth + sizeThatFitsWidthCeiled).roundToDisplayScale()
            sizeThatFits.width = min(Self.shouldUseNewLayout ? sizeThatFitsWidthCeiled : sizeThatFits.width, scrollableDimensionStretchLimit ?? .greatestFiniteMagnitude)
            let size = info.customSize ?? sizeThatFits
            switch alignment {
            case .top:
                view.frame = CGRect(minX: maxX, minY: minY, size: size)
            case .bottom:
                view.frame = CGRect(minX: maxX, maxY: bounds.height + minY, size: size)
            case .center:
                view.frame = CGRect(minX: maxX, midY: bounds.midY, size: size)
            // layout illegal alignment same as fill
            case .fill,
                 .leading,
                 .trailing:
                view.frame = CGRect(x: maxX, y: minY, width: size.width, height: bounds.height)
            }

            let spacing = info.customSpacing ?? self.spacing
            maxX = view.frame.maxX + spacing
        }
    }

    private func removeIfExist(view: UIView) {
        let index = _indexesHelper.index(of: view)
        if index != NSNotFound {
            _indexesHelper.removeObject(at: index)
            _arrangedSubviewInfos.remove(at: index)
        }
    }
}

// MARK: - Util

private extension ManualLayoutBasedStackView {
    private struct ArrangedSubviewInfo {
        let view: UIView
        var customAlignment: Alignment?
        var customSpacing: CGFloat?
        var customSize: CGSize?
    }
}
