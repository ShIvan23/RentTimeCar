//
//  ClientItemsViewController.swift
//  RentTimeCar
//

import PinLayout
import UIKit

final class ClientItemsViewController: UIViewController {

    // MARK: - Mode

    enum Mode {
        case rents
        case fines
    }

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
        collectionView.register(cell: FineCell.self)
        collectionView.register(cell: ShimmerCarCell.self)
        return collectionView
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryTextColor
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    // MARK: - Private Properties

    private let mode: Mode
    private let coordinator: ICoordinator
    private let rentApiFacade: IRentApiFacade
    private var requests: [ClientRequest] = []
    private var fines: [FineDto] = []
    private var isLoading = false

    // MARK: - Init

    init(mode: Mode, coordinator: ICoordinator, rentApiFacade: IRentApiFacade) {
        self.mode = mode
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
        fetchItems()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        performLayout()
    }

    // MARK: - Private Methods

    private func setupView() {
        view.backgroundColor = .mainBackground
        view.addSubviews([collectionView, emptyLabel])
        navigationController?.isNavigationBarHidden = false

        switch mode {
        case .rents:
            emptyLabel.text = "Нет заявок"
        case .fines:
            emptyLabel.text = "Нет штрафов"
        }
    }

    private func performLayout() {
        collectionView.pin.all()

        emptyLabel.pin
            .horizontally(16)
            .vCenter()
            .sizeToFit(.width)
    }

    private func fetchItems() {
        guard let integrationId = AuthService.shared.client?.integrationId else {
            emptyLabel.isHidden = false
            return
        }
        isLoading = true
        collectionView.reloadData()
        switch mode {
        case .rents:
            fetchRequests(integrationId: integrationId)
        case .fines:
            fetchFines(integrationId: integrationId)
        }
    }

    private func fetchRequests(integrationId: String) {
        rentApiFacade.getClientRequests(clientIntegrationId: integrationId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                switch result {
                case let .success(response):
                    self.requests = response.result?.requests ?? []
                    self.emptyLabel.isHidden = !self.requests.isEmpty
                    self.collectionView.reloadData()
                case .failure:
                    self.emptyLabel.isHidden = false
                    self.collectionView.reloadData()
                }
            }
        }
    }

    private func fetchFines(integrationId: String) {
        rentApiFacade.getClientFines(clientIntegrationId: integrationId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                switch result {
                case let .success(response):
                    let fines = response.result?.fines ?? []
                    self.fines = fines
                    self.emptyLabel.isHidden = !fines.isEmpty
                    self.collectionView.reloadData()
                case .failure:
                    self.emptyLabel.isHidden = false
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ClientItemsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isLoading { return 6 }
        switch mode {
        case .rents: return requests.count
        case .fines: return fines.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isLoading {
            let cell: ShimmerCarCell = collectionView.dequeueCell(for: indexPath)
            return cell
        }
        switch mode {
        case .rents:
            let cell: ClientRequestCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(with: requests[indexPath.item])
            return cell
        case .fines:
            let cell: FineCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(with: fines[indexPath.item])
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ClientItemsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.bounds.width - 32
        if isLoading {
            switch mode {
            case .rents: return CGSize(width: width, height: 96)
            case .fines: return CGSize(width: width, height: 110)
            }
        }
        switch mode {
        case .rents: return CGSize(width: width, height: 96)
        case .fines: return CGSize(width: width, height: 110)
        }
    }
}
