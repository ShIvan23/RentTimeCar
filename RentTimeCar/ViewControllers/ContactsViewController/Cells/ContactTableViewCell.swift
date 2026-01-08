//
//  ContactTableViewCell.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 08.01.2026.
//

import UIKit

final class ContactTableViewCell: UITableViewCell {

    // MARK: - UI

    private var secondaryButton = SecondaryButton()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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

    // MARK: - Internal Methods

    func configure(with model: ContactsModel) {
        secondaryButton.setTitle(model.title, for: .normal)
    }

    // MARK: - Private Methods

    private func setupView() {
        contentView.addSubview(secondaryButton)
        contentView.backgroundColor = .mainBackground
        secondaryButton.isUserInteractionEnabled = false
    }

    private func performLayout() {
        secondaryButton.pin
            .all()
            .marginHorizontal(20)
            .marginVertical(5)
    }
}
