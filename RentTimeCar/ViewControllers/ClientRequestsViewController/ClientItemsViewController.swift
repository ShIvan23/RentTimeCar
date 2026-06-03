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
        let requests: [ContractDto]
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        performLayout()
    }

    // MARK: - Private Methods

    private func setupView() {
        view.backgroundColor = .mainBackground
        view.addSubviews([collectionView, emptyLabel])

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
        if AuthService.shared.phoneNumber == Self.reviewPhoneNumber,
           AuthService.shared.client == nil {
            applyDemoData()
            return
        }
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

    private func applyDemoData() {
        switch mode {
        case .rents:
            let contracts = Self.demoContracts
            sections = makeSections(from: contracts)
            emptyLabel.isHidden = !contracts.isEmpty
        case .fines:
            let fines = Self.demoFines
            fineGroups = makeFineGroups(from: fines)
            expandedGroupIndices = []
            emptyLabel.isHidden = !fines.isEmpty
        }
        collectionView.reloadData()
    }

    private func fetchRequests(integrationId: String) {
        rentApiFacade.getClientContracts(clientIntegrationId: integrationId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                switch result {
                case let .success(response):
                    let requests = response.result?.contracts ?? []
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

    private func makeSections(from contracts: [ContractDto]) -> [RentSection] {
        let active = contracts.filter { !$0.isCompleted }
        let completed = contracts.filter { $0.isCompleted }
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
            cell.onFineTap = { [weak self] fine in
                self?.coordinator.openFineDetailViewController(fine: fine)
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

// MARK: - Demo Data

private extension ClientItemsViewController {

    static let reviewPhoneNumber = "79111111111"

    static let demoContracts: [ContractDto] = {
        let json = """
        [
            {
                "ID": 1001,
                "DateFrom": "01.05.2026 10:00:00",
                "DateTo": "10.05.2026 10:00:00",
                "Vehicle": "Mercedes-Benz E-Class, 2022, Белый",
                "VehicleId": 0,
                "ContractNumber": "ТД-2026-001",
                "ContractState": 8,
                "CustomContractState": 0,
                "ContractType": 1,
                "TotalBalanceSum": 45000,
                "FinesGBDDBalance": 0,
                "DepositBalance": 10000,
                "RentBalance": 35000,
                "AddServicesBalance": 0,
                "OtherBalance": 0
            },
            {
                "ID": 1002,
                "DateFrom": "15.01.2026 12:00:00",
                "DateTo": "20.01.2026 12:00:00",
                "Vehicle": "BMW 5 Series, 2021, Чёрный",
                "VehicleId": 0,
                "ContractNumber": "ТД-2026-002",
                "ContractState": 9,
                "CustomContractState": 0,
                "ContractType": 1,
                "TotalBalanceSum": 30000,
                "FinesGBDDBalance": 0,
                "DepositBalance": 10000,
                "RentBalance": 20000,
                "AddServicesBalance": 0,
                "OtherBalance": 0
            }
        ]
        """
        return (try? JSONDecoder().decode([ContractDto].self, from: Data(json.utf8))) ?? []
    }()

    static let demoFines: [FineDto] = {
        let json = """
        [
            {
                "Id": 2001,
                "DocumentType": 0,
                "GibddStatus": 0,
                "CalculationStatus": 0,
                "DiscountEffectCountDays": 20,
                "PayToDueDate": "01.07.2026 00:00:00",
                "VehicleGibddNumber": "А123БВ777",
                "Vehicle": "Mercedes-Benz E-Class, 2022, Белый",
                "ContractNumber": "ТД-2026-001",
                "Sum": 500,
                "ToPaymentSum": 250,
                "ViolationDate": "05.05.2026 14:30:00",
                "KoapEntityDescription": "Превышение скорости от 20 до 40 км/ч",
                "DiscountEffectTitle": "Скидка 50% при оплате в течение 20 дней"
            }
        ]
        """
        return (try? JSONDecoder().decode([FineDto].self, from: Data(json.utf8))) ?? []
    }()
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ClientItemsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard mode == .rents, !sections.isEmpty else { return }
        let contract = sections[indexPath.section].requests[indexPath.item]
        coordinator.openRentDetailViewController(contract: contract)
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

