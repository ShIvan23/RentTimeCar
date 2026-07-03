//
//  CollapsibleSectionView.swift
//  RentTimeCar
//

import PinLayout
import UIKit

final class CollapsibleSectionView: UIView {

    var isExpanded: Bool {
        didSet { updateChevron() }
    }

    var onToggle: (() -> Void)?

    private let headerView = UIView()
    private let titleLabel = Label(fontSize: 16, weight: .bold, textAlignment: .natural)
    private let totalLabel = Label(fontSize: 16, weight: .bold, textAlignment: .right)
    private let chevronImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .secondaryTextColor
        return iv
    }()

    private let itemsContainerView: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()

    private var itemViews: [UIView] = []
    private var separators: [UIView] = []

    init(title: String, total: String, totalColor: UIColor, items: [UIView], expanded: Bool = true) {
        self.isExpanded = expanded
        super.init(frame: .zero)
        backgroundColor = .secondaryBackground
        layer.cornerRadius = 12
        clipsToBounds = true

        titleLabel.text = title
        totalLabel.text = total
        totalLabel.textColor = totalColor
        updateChevron(animated: false)

        headerView.addSubview(titleLabel)
        headerView.addSubview(totalLabel)
        headerView.addSubview(chevronImageView)
        addSubview(headerView)
        addSubview(itemsContainerView)

        itemViews = items
        items.forEach { itemsContainerView.addSubview($0) }

        for i in 0..<max(items.count - 1, 0) {
            let sep = UIView()
            sep.backgroundColor = UIColor.white.withAlphaComponent(0.07)
            itemsContainerView.addSubview(sep)
            separators.append(sep)
            _ = i
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
        headerView.addGestureRecognizer(tap)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    private func updateChevron(animated: Bool = false) {
        let angle: CGFloat = isExpanded ? .pi : 0
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.chevronImageView.transform = CGAffineTransform(rotationAngle: angle)
            }
        } else {
            chevronImageView.transform = CGAffineTransform(rotationAngle: angle)
        }
    }

    @objc private func headerTapped() {
        isExpanded.toggle()
        updateChevron(animated: true)
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: .curveEaseInOut) {
            self.layoutSubviews()
            self.onToggle?()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let hPad: CGFloat = 16
        let headerH: CGFloat = 52

        headerView.pin.top().horizontally().height(headerH)

        chevronImageView.pin.right(hPad).vCenter().size(16)
        totalLabel.pin.before(of: chevronImageView).marginRight(6).vCenter().sizeToFit()
        titleLabel.pin.left(hPad).vCenter().before(of: totalLabel).marginRight(8).sizeToFit(.width)

        if isExpanded && !itemViews.isEmpty {
            itemsContainerView.pin.below(of: headerView).horizontally()

            var y: CGFloat = 0
            for (i, item) in itemViews.enumerated() {
                let h = item.sizeThatFits(CGSize(width: itemsContainerView.bounds.width, height: .infinity)).height
                item.pin.top(y).horizontally().height(h)
                y += h
                if i < separators.count {
                    separators[i].pin.top(y).horizontally(hPad).height(1)
                    y += 1
                }
            }
            itemsContainerView.pin.height(y)
        } else {
            itemsContainerView.pin.top(headerH).horizontally().height(0)
        }

        let totalH = headerH + (isExpanded ? itemsContainerView.frame.height : 0)
        if frame.height != totalH { frame.size.height = totalH }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        frame = CGRect(origin: .zero, size: CGSize(width: size.width, height: 0))
        layoutSubviews()
        return CGSize(width: size.width, height: frame.height)
    }
}
