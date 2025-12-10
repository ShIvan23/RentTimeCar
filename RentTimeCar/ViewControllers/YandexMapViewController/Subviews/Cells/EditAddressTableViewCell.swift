//
//  EditAddressTableViewCell.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 09.12.2025.
//

import UIKit

final class EditAddressTableViewCell: UITableViewCell {
    // MARK: - UI

    private let title = Label(
        numberOfLines: 1,
        fontSize: 12,
        textAlignment: .left
    )
    private let address = Label(
        numberOfLines: 2,
        fontSize: 14,
        textAlignment: .left
    )
    private let editImageView = UIImageView()

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

    func configure(with model: EditAddressModel) {
        title.text = model.title
        address.text = model.address
        setNeedsLayout()
    }

    // MARK: - Private Methods

    private func setupView() {
        contentView.addSubviews([title, address, editImageView])
        editImageView.image = .pencil.withRenderingMode(.alwaysTemplate)
        editImageView.tintColor = .red
        contentView.backgroundColor = .clear
    }

    private func performLayout() {
        editImageView.pin
            .right()
            .vCenter()
            .marginRight(12)
            .size(CGSize(square: 18))

        title.pin
            .topLeft()
            .marginLeft(10)
            .marginTop(4)
            .sizeToFit()

        address.pin
            .below(of: title, aligned: .left)
            .marginTop(2)
            .right(to: editImageView.edge.left)
            .marginRight(8)
            .sizeToFit(.width)
    }
}
