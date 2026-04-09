//
//  SearchAddressViewController.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 25.11.2025.
//

import YandexMapsMobile
import UIKit

protocol SearchAddressViewControllerDelegate: AnyObject {
    func search(uri: String?)
}

final class SearchAddressViewController: UIViewController {
    
    // MARK: - UI
    
    private lazy var searchController = UISearchController(searchResultsController: searchResultsTableViewController)
    private let searchResultsTableViewController = SearchResultsTableViewController()
    
    // MARK: - Private Properties
    
    private var searchSession: YMKSearchSession?
    private lazy var searchManager = YMKSearchFactory.instance().createSearchManager(with: .combined)
    private lazy var suggestSession: YMKSearchSuggestSession = searchManager.createSuggestSession()
    private weak var delegate: SearchAddressViewControllerDelegate?
    private let coordinator: ICoordinator
    
    // MARK: - Init
    
    init(
        coordinator: ICoordinator,
        delegate: SearchAddressViewControllerDelegate
    ) {
        self.coordinator = coordinator
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        view.backgroundColor = .mainBackground
        searchController.searchBar.placeholder = "Введите адрес"
        searchController.searchBar.delegate = self

        navigationItem.searchController = searchController
        
    }
    
    private func stopSearch() {
        searchSession?.cancel()
        searchSession = nil
        resetSuggest()
    }
    
    private func resetSuggest() {
        suggestSession.reset()
    }
    
    private func searchSuggests(text: String) {
        suggestSession.suggest(
            withText: text,
            window: YMKBoundingBox(),
            suggestOptions: YMKSuggestOptions(
                suggestTypes: [.biz, .geo, .transit],
                userPosition: nil,
                suggestWords: true,
                strictBounds: false
            )) { [weak self] responseSuggest, error in
                guard let self else { return }
                
                if let error {
                    print("+++ надо показать ошибку саджестов")
                    return
                }
                
                guard let items = responseSuggest?.items else { return }
                let suggestItems = items
                    .filter { $0.uri != nil }
                    .map { item in
                        SuggestItem(
                            title: item.title,
                            subtitle: item.subtitle) { [weak self] in
                                self?.delegate?.search(uri: item.uri)
                                self?.coordinator.popViewController()
                            }
                    }
                searchResultsTableViewController.items = suggestItems
                searchResultsTableViewController.tableView.reloadData()
            }
    }
}

// MARK: - UISearchBarDelegate

extension SearchAddressViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        stopSearch()
        searchSuggests(text: searchText)
    }
}
