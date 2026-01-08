//
//  ContactsViewController.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 08.01.2026.
//

import UIKit

final class ContactsViewController: UIViewController {

    // MARK: - UI

    private let button = MainButton(title: "Назад")
    private let tableView = UITableView()

    // MARK: - Private Properties

    private let model = ContactsModel.makeModel()
    private let coordinator: ICoordinator

    // MARK: - Init

    init(
        coordinator: ICoordinator
    ) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

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
        view.addSubviews([tableView, button])
        view.backgroundColor = .mainBackground
        setupTableView()
        button.action = { [weak self] in
            self?.coordinator.dismissViewController()
        }
    }

    private func setupTableView() {
        tableView.register(cell: ContactTableViewCell.self)
        tableView.contentInset = .init(top: 30)
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
    }

    private func performLayout() {
        button.pin
            .bottom(view.safeAreaInsets.bottom)
            .horizontally()
            .marginHorizontal(20)
            .height(50)

        tableView.pin
            .top()
            .horizontally()
            .bottom(to: button.edge.top)
    }
}

// MARK: - UITableViewDataSource

extension ContactsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ContactTableViewCell = tableView.dequeueCell(for: indexPath)
        let item = model[indexPath.row]
        cell.configure(with: item)
        return cell
    }
}

// MARK: - UITableViewDataSource

extension ContactsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = model[safe: indexPath.row]?.type else { return }
        let phone = "+79268202557"
        let url: URL?
        switch type {
        case .call:
            url = URL(string: "tel://\(phone)")
        case .telegram:
            url = URL(string: "https://t.me/\(phone)")
        case .whatsApp:
            url = URL(string: "https://api.whatsapp.com/send?phone=\(phone)")
        }
        guard let url else { return }
        coordinator.openAnotherApplication(url: url)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
}
