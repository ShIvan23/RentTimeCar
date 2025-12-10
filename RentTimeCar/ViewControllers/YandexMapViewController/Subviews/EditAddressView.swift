//
//  EditAddressView.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 09.12.2025.
//

import UIKit

struct EditAddressModel {
    let title: String
    let address: String
}

final class EditAddressView: UIView {

    // MARK: - Private Properties

    private var model: [EditAddressModel] = []

    // MARK: - UI

    private let tableView = UITableView()

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

    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        CGSize(width: size.width,
               height: CGFloat(model.count) * .cellHeight)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        performLayout()
    }

    // MARK: - Internal Methods

    func configure(with model: [EditAddressModel]) {
        self.model = model
        tableView.reloadData()
        setNeedsLayout()
    }

    // MARK: - Private Methods

    private func setupView() {
        addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(cell: EditAddressTableViewCell.self)
        tableView.layer.cornerRadius = 12
        tableView.backgroundColor = .black
    }

    private func performLayout() {
        tableView.pin.all()
    }
}

// MARK: - UITableViewDataSource

extension EditAddressView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: EditAddressTableViewCell = tableView.dequeueCell(for: indexPath)
        cell.configure(with: model[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension EditAddressView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("+++ didSelectRowAt = \(model[indexPath.row])")
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        .cellHeight
    }
}


private extension CGFloat {
    static let cellHeight: CGFloat = 70
}
