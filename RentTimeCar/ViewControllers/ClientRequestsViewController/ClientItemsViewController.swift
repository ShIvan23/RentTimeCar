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

    // MARK: - Private Types

    private struct RentSection {
        let title: String
        let requests: [ClientRequest]
    }

    // MARK: - UI

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .mainBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cell: ClientRequestCell.self)
        collectionView.register(cell: FineGroupCell.self)
        collectionView.register(cell: ShimmerCarCell.self)
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier
        )
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
    private var sections: [RentSection] = []
    private var fineGroups: [FineGroup] = []
    private var expandedGroupIndices: Set<Int> = []
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
                    let requests = response.result?.requests ?? []
                    self.sections = self.makeSections(from: requests)
                    self.emptyLabel.isHidden = !requests.isEmpty
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
                    self.fineGroups = self.makeFineGroups(from: fines)
                    self.expandedGroupIndices = []
                    self.emptyLabel.isHidden = !self.fineGroups.isEmpty
                    self.collectionView.reloadData()
                case .failure:
                    self.emptyLabel.isHidden = false
                    self.collectionView.reloadData()
                }
            }
        }
    }

    private func makeFineGroups(from fines: [FineDto]) -> [FineGroup] {
        var dict: [String: [FineDto]] = [:]
        for fine in fines {
            let key = fine.contractNumber ?? fine.vehicle ?? fine.vehicleGibddNumber ?? "other"
            dict[key, default: []].append(fine)
        }
        return dict.map { _, groupFines in
            FineGroup(
                vehicle: groupFines.first?.vehicle,
                contractNumber: groupFines.first?.contractNumber,
                fines: groupFines.sorted { ($0.violationDate ?? .distantPast) < ($1.violationDate ?? .distantPast) }
            )
        }.sorted {
            ($0.fines.first?.violationDate ?? .distantPast) > ($1.fines.first?.violationDate ?? .distantPast)
        }
    }

    private func makeSections(from requests: [ClientRequest]) -> [RentSection] {
        let hiddenSteps = ["Данные клиента"]
        let filtered = requests.filter { req in
            !hiddenSteps.contains(where: { req.currentStep.localizedCaseInsensitiveContains($0) })
        }
        let active = filtered.filter { !$0.isCompleted }
        let completed = filtered.filter { $0.isCompleted }
        var result: [RentSection] = []
        if !active.isEmpty {
            result.append(RentSection(title: "Активные", requests: active))
        }
        if !completed.isEmpty {
            result.append(RentSection(title: "Завершенные", requests: completed))
        }
        return result
    }
}

// MARK: - UICollectionViewDataSource

extension ClientItemsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if isLoading { return 1 }
        switch mode {
        case .rents: return max(sections.count, 1)
        case .fines: return 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isLoading { return 6 }
        switch mode {
        case .rents:
            guard !sections.isEmpty else { return 0 }
            return sections[section].requests.count
        case .fines:
            return fineGroups.count
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
            cell.configure(with: sections[indexPath.section].requests[indexPath.item])
            return cell
        case .fines:
            let cell: FineGroupCell = collectionView.dequeueCell(for: indexPath)
            let index = indexPath.item
            let isExpanded = expandedGroupIndices.contains(index)
            cell.configure(group: fineGroups[index], isExpanded: isExpanded)
            cell.onToggle = { [weak self] in
                guard let self else { return }
                if self.expandedGroupIndices.contains(index) {
                    self.expandedGroupIndices.remove(index)
                } else {
                    self.expandedGroupIndices.insert(index)
                }
                self.collectionView.reloadItems(at: [indexPath])
            }
            return cell
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              mode == .rents,
              !sections.isEmpty else {
            return UICollectionReusableView()
        }
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier,
            for: indexPath
        ) as? SectionHeaderView
        header?.configure(with: sections[indexPath.section].title)
        return header ?? UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ClientItemsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard mode == .rents, !sections.isEmpty else { return }
        let request = sections[indexPath.section].requests[indexPath.item]
        coordinator.openRentDetailViewController(request: request)
    }
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.bounds.width - 32
        if isLoading {
            return CGSize(width: width, height: 100)
        }
        switch mode {
        case .rents: return CGSize(width: width, height: 100)
        case .fines:
            let index = indexPath.item
            let isExpanded = expandedGroupIndices.contains(index)
            let count = fineGroups[index].fines.count
            return CGSize(width: width, height: FineGroupCell.height(fineCount: count, isExpanded: isExpanded))
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        guard mode == .rents, !sections.isEmpty else { return .zero }
        return CGSize(width: collectionView.bounds.width, height: 36)
    }
}

