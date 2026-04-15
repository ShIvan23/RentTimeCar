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
    private let errorLabel = Label(
        text: "Не удалось загрузить контакты",
        fontSize: 14,
        textColor: .secondaryTextColor
    )
    private let retryButton = MainButton(title: "Попробовать снова")

    // MARK: - Private Properties

    private var contacts = [Contact]()
    private let coordinator: ICoordinator
    private let contactsService = ContactsService.shared

    // MARK: - Init

    init(coordinator: ICoordinator) {
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
        fetchContacts()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        performLayout()
    }

    // MARK: - Private Methods

    private func setupView() {
        view.addSubviews([tableView, errorLabel, retryButton, button])
        view.backgroundColor = .mainBackground
        setupTableView()
        setErrorViewHidden(true)
        button.action = { [weak self] in
            self?.coordinator.dismissViewController()
        }
        retryButton.action = { [weak self] in
            self?.fetchContacts()
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

    private func setErrorViewHidden(_ hidden: Bool) {
        errorLabel.isHidden = hidden
        retryButton.isHidden = hidden
        tableView.isHidden = !hidden
    }

    private func fetchContacts() {
        setErrorViewHidden(true)
        contactsService.getContacts { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case let .success(items):
                    self.contacts = items
                    self.tableView.reloadData()
                case .failure:
                    self.setErrorViewHidden(false)
                    self.view.setNeedsLayout()
                }
            }
        }
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

        errorLabel.pin
            .vCenter(-33)
            .horizontally(20)
            .sizeToFit(.width)

        retryButton.pin
            .below(of: errorLabel)
            .horizontally(20)
            .marginTop(16)
            .height(50)
    }
}

// MARK: - UITableViewDataSource

extension ContactsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ContactTableViewCell = tableView.dequeueCell(for: indexPath)
        cell.configure(with: contacts[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ContactsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let contact = contacts[safe: indexPath.row] else { return }
        let phone = contact.phoneNumber
        let url: URL?
        switch contact.type {
        case .phone:
            url = URL(string: "tel://\(phone)")
        case .telegram:
            url = URL(string: "https://t.me/\(phone)")
        case .whatsapp:
            url = URL(string: "https://api.whatsapp.com/send?phone=\(phone)")
        case .max:
            url = URL(string: "https://max.ru/u/\(phone)")
        }
        guard let url else { return }
        coordinator.openAnotherApplication(url: url)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
}
