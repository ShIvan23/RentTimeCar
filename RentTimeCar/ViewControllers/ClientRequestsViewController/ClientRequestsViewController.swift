//
//  ClientRequestsViewController.swift
//  RentTimeCar
//

import PinLayout
import UIKit

final class ClientRequestsViewController: UIViewController {

    // MARK: - UI

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .mainBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cell: ClientRequestCell.self)
        return collectionView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .whiteTextColor
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Нет заявок"
        label.textColor = .secondaryTextColor
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    // MARK: - Private Properties

    private let coordinator: ICoordinator
    private let rentApiFacade: IRentApiFacade
    private var requests: [ClientRequest] = []

    // MARK: - Init

    init(coordinator: ICoordinator, rentApiFacade: IRentApiFacade) {
        self.coordinator = coordinator
        self.rentApiFacade = rentApiFacade
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fetchRequests()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        performLayout()
    }

    // MARK: - Private Methods

    private func setupView() {
        view.backgroundColor = .mainBackground
        view.addSubviews([collectionView, activityIndicator, emptyLabel])
        navigationController?.isNavigationBarHidden = false
    }

    private func performLayout() {
        collectionView.pin.all()

        activityIndicator.pin
            .hCenter()
            .vCenter()
            .sizeToFit()

        emptyLabel.pin
            .hCenter()
            .vCenter()
            .horizontally(16)
            .sizeToFit(.width)
    }

    private func fetchRequests() {
        guard let integrationId = AuthService.shared.integrationId else {
            emptyLabel.isHidden = false
            return
        }
        activityIndicator.startAnimating()
        rentApiFacade.getClientRequests(clientIntegrationId: integrationId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.activityIndicator.stopAnimating()
                switch result {
                case let .success(response):
                    self.requests = response.result?.requests ?? []
                    self.emptyLabel.isHidden = !self.requests.isEmpty
                    self.collectionView.reloadData()
                case .failure:
                    self.emptyLabel.isHidden = false
                }
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ClientRequestsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        requests.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ClientRequestCell = collectionView.dequeueCell(for: indexPath)
        cell.configure(with: requests[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ClientRequestsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width - 32, height: 96)
    }
}
