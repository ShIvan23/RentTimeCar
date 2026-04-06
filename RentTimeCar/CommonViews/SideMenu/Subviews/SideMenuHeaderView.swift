//
//  SideMenuHeaderView.swift
//  RentTimeCar
//

import PinLayout
import UIKit

final class SideMenuHeaderView: UIView {
    // MARK: - UI

    private let phoneLabel = Label(fontSize: 16, textAlignment: .left)
    private let nameLabel = Label(fontSize: 14, textAlignment: .left)

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        autoSizeThatFits(size, layoutClosure: performLayout)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        performLayout()
    }

    // MARK: - Internal Methods

    func configure(phone: String?, name: String?) {
        phoneLabel.text = phone
        let trimmedName = name?.trimmingCharacters(in: .whitespaces)
        nameLabel.text = trimmedName
        nameLabel.isHidden = trimmedName?.isEmpty != false
        setNeedsLayout()
    }

    // MARK: - Private Methods

    private func setupView() {
        addSubviews([phoneLabel, nameLabel])
        nameLabel.alpha = 0.7
    }

    private func performLayout() {
        phoneLabel.pin
            .top(16)
            .horizontally(20)
            .sizeToFit(.width)

        if nameLabel.isHidden {
            pin.wrapContent(.vertically, padding: PEdgeInsets(top: 16, left: 0, bottom: 16, right: 0))
        } else {
            nameLabel.pin
                .below(of: phoneLabel)
                .marginTop(4)
                .horizontally(20)
                .sizeToFit(.width)

            pin.wrapContent(.vertically, padding: PEdgeInsets(top: 16, left: 0, bottom: 16, right: 0))
        }
    }
}
