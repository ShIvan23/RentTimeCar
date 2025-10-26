//
//  FilterViewController.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 14.08.2025.
//

import PinLayout
import UIKit

final class FilterViewController: UIViewController {
    // MARK: - UI
    
    private let confirmButton = MainButton()
    private let buttonContainerView = UIView()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = .collectionViewInterItemSpacing
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .mainBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
//        collectionView.prefetchDataSource = self
        collectionView.register(cell: FilterDateCell.self)
        collectionView.register(cell: SeparatorCell.self)
        collectionView.register(cell: BrandAutoCell.self)
        collectionView.register(cell: TitleCell.self)
        collectionView.register(cell: FilterValueCell.self)
        collectionView.register(cell: FilterClassCell.self)
        return collectionView
    }()
    
    // MARK: - Private Properties
    
    private let coordinator: ICoordinator
    private let rentApiFacade: IRentApiFacade
    private var model = [FilterVCType]()
    private let filterService = FilterService.shared
    
    // MARK: Init
    
    init(
        coordinator: ICoordinator,
        rentApiFacade: IRentApiFacade
    ) {
        self.coordinator = coordinator
        self.rentApiFacade = rentApiFacade
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addTapGesture()
        addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        addObservers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        performLayout()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        view.backgroundColor = .mainBackground
        view.addSubviews([collectionView, buttonContainerView])
        buttonContainerView.addSubview(confirmButton)
        buttonContainerView.backgroundColor = .secondaryBackground
        model = FilterVCType.makeDefaultModel()
        if filterService.hasFilters {
            updateConfirmButtonTitle(autoCount: filterService.filteredAutos.count)
        } else {
            updateConfirmButtonTitle(autoCount: model.count)
        }
        
        confirmButton.action = { [weak self] in
            guard let self else { return }
            coordinator.popViewController()
        }
    }
    
    private func performLayout() {
        buttonContainerView.pin
            .bottom()
            .horizontally()
            .height(view.safeAreaInsets.bottom + .buttonHeight + .buttonVerticalMargin * 2)
        
        confirmButton.pin
            .top()
            .horizontally()
            .marginVertical(.buttonVerticalMargin)
            .marginHorizontal(16)
            .height(.buttonHeight)
        
        collectionView.pin
            .top(view.safeAreaInsets)
            .horizontally()
            .bottom(to: buttonContainerView.edge.top)
    }
    
    private func updateConfirmButtonTitle(autoCount: Int) {
        confirmButton.setTitle("Показать \(autoCount) предложений", for: .normal)
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func tapAction() {
        view.endEditing(true)
    }
}

private extension CGFloat {
    static let buttonHeight: CGFloat = 50
    static let buttonVerticalMargin: CGFloat = 8
    static let collectionViewHorizontalInset: CGFloat = 18
    static let collectionViewInterItemSpacing: CGFloat = 8
}

// MARK: - UICollectionViewDataSource

extension FilterViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        model.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellType = model[indexPath.item]
        switch cellType {
        case let .date(selectedDates):
            let cell: FilterDateCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(selectedDates: selectedDates)
            return cell
        case .separator:
            let cell: SeparatorCell = collectionView.dequeueCell(for: indexPath)
            return cell
        case let .brandAuto(filterBrand):
            let cell: BrandAutoCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(with: filterBrand)
            return cell
        case let .title(text):
            let cell: TitleCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(with: text)
            return cell
        case let .price(priceModel):
            let cell: FilterValueCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(
                with: priceModel,
                cellType: .price
            )
            cell.delegate = self
            return cell
        case let .motorPower(motorPowerModel):
            let cell: FilterValueCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(
                with: motorPowerModel,
                cellType: .motorPower
            )
            cell.delegate = self
            return cell
        case let .classAuto(classModel):
            let cell: FilterClassCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(with: classModel)
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate

extension FilterViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellType = model[indexPath.item]
        let horizontalContentInsets = .collectionViewHorizontalInset * 2
        let availableWidth = collectionView.bounds.width - horizontalContentInsets
        switch cellType {
        case .date:
            return CGSize(width: availableWidth, height: 86)
        case .separator:
            return CGSize(width: availableWidth, height: 1)
        case .brandAuto:
            let availableWidth = availableWidth - .collectionViewInterItemSpacing * 2 - .collectionViewHorizontalInset * 2
            let cellWidth = availableWidth / 3
            return CGSize(square: cellWidth)
        case let .title(text):
            let textHeight = (text as NSString).size(withAttributes: [.font: UIFont.openSans() ?? .systemFont(ofSize: 16)]).height
            return CGSize(width: collectionView.bounds.width - horizontalContentInsets, height: textHeight)
        case .motorPower, .price:
            return CGSize(width: availableWidth, height: .filterValueCellMinMaxViewHeight + .filterValueCellDoubleSliderTopMargin + .filterValueCellDoubleSliderHeight)
        case let .classAuto(classModel):
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.openSans(fontSize: 16) ?? .systemFont(ofSize: 16),
            ]
            let attributedStringSize = NSAttributedString(string: classModel.name, attributes: attributes).size()
            return CGSize(
                width: attributedStringSize.width + .filterClassCellHorizontalMargin * 2,
                height: attributedStringSize.height + .filterClassCellVerticalMargin * 2
            )
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellType = model[indexPath.item]
        switch cellType {
        case .date:
            coordinator.openCalendarViewController()
            return
        case .separator, .title, .motorPower, .price:
            break
        case let .brandAuto(brandAutoModel):
            let brandAutoModel = FilterBrandAuto(
                name: brandAutoModel.name,
                image: brandAutoModel.image,
                isSelected: !brandAutoModel.isSelected
            )
            model[indexPath.item] = .brandAuto(brandAutoModel)
            collectionView.reloadData()
        case let .classAuto(classAutoModel):
            let filterClassModel = FilterClassAuto(
                name: classAutoModel.name,
                isSelected: !classAutoModel.isSelected
            )
            model[indexPath.item] = .classAuto(filterClassModel)
            collectionView.reloadData()
        }
        updateConfirmButton()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: .collectionViewHorizontalInset, bottom: 12, right: .collectionViewHorizontalInset)
    }
}

// MARK: - FilterValueCellDelegate

extension FilterViewController: FilterValueCellDelegate {
    func filterValuesChanged(newModel: FilterValueModel, cellType: FilterValueCell.CellType) {
        switch cellType {
        case .price:
            let priceCellIndex = model.firstIndex { cellType in
                switch cellType {
                case .price:
                    true
                default:
                    false
                }
            }
            guard let priceCellIndex,
                  model[safe: priceCellIndex] != nil else { return }
            model[priceCellIndex] = .price(newModel)
            filterService.setSelectedPrice(min: newModel.minValueNow, max: newModel.maxValueNow)
        case .motorPower:
            let priceCellIndex = model.firstIndex { cellType in
                switch cellType {
                case .motorPower:
                    true
                default:
                    false
                }
            }
            guard let priceCellIndex,
                  model[safe: priceCellIndex] != nil else { return }
            model[priceCellIndex] = .motorPower(newModel)
        }
    }
}

// MARK: - Notification Center

extension FilterViewController {
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(selectedDatesUpdate), name: .selectedDatesUpdated, object: nil)
    }
    
    @objc
    private func keyboardShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        collectionView.contentInset.bottom = keyboardSize.height
        collectionView.scrollIndicatorInsets = .init(top: .zero,
                                                     left: .zero,
                                                     bottom: keyboardSize.height,
                                                     right: .zero)
    }
    
    @objc
    private func keyboardHide() {
        collectionView.contentInset.bottom = .zero
        collectionView.verticalScrollIndicatorInsets = .zero
    }
    
    @objc
    private func selectedDatesUpdate() {
        let selectedDates = FilterService.shared.selectedDates
        let dateCellIndex = model.firstIndex {
            switch $0 {
            case .date:
                true
            default:
                false
            }
        }
        guard let dateCellIndex,
              model[safe: dateCellIndex] != nil else { return }
        model[dateCellIndex] = .date(selectedDates)
        collectionView.reloadData()
        updateConfirmButton()
    }
}

// MARK: - Filter Operations

private extension FilterViewController {
    func filterSelectedBrands() -> [String] {
        var selectedBrands: [String] = []
        model.forEach {
            switch $0 {
            case let .brandAuto(brandModel):
                if brandModel.isSelected {
                    selectedBrands.append(brandModel.name)
                }
            default:
                break
            }
        }
        filterService.setSelectedBrands(selectedBrands)
        return selectedBrands
    }
    
    func updateConfirmButton() {
        let selectedBrands = filterSelectedBrands()
        let selectedDates = filterService.selectedDates
        let input = SearchAutoInput(
            dateFrom: selectedDates.first?.convertDateToString() ?? .defaultDate,
            dateTo: selectedDates.last?.convertDateToString() ?? .defaultDate,
            brands: selectedBrands,
            defaultPriceFrom: filterService.selectedPrice.min,
            defaultPriceTo: filterService.selectedPrice.max
        )
        rentApiFacade.searchAuto(with: input) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(model):
                    self?.updateConfirmButtonTitle(autoCount: model.result?.count ?? .zero)
                    // тут слабая ссылка, если уйти с экрана, то не отработает
                    self?.filterService.setFilteredAutos(model.result ?? [])
                    NotificationCenter.default.post(name: .filteredAutosUpdated, object: nil)
                case let .failure(error):
                    print("+++ error = \(error)")
                }
            }
        }
    }
}

private extension String {
    static let defaultDate = "1900.01.01 00:00:00"
}
