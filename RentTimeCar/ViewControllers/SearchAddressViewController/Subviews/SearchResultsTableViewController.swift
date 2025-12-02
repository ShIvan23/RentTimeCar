//
//  SearchResultsTableViewController.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 02.12.2025.
//

import YandexMapsMobile
import UIKit

final class SearchResultsTableViewController: UITableViewController {

    private let cellIdentifier = "cellIdentifier"

    var items = [SuggestItem]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.delegate = self
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.numberOfLines = 0

        let item = items[indexPath.row]

        cell.textLabel?.attributedText = item.cellText

        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = items[safe: indexPath.row] else { return }
        item.onClick()
    }
}

struct SuggestItem {
    let title: YMKSpannableString
    let subtitle: YMKSpannableString?
    let onClick: () -> Void
}

extension SuggestItem {
    var cellText: NSAttributedString {
        let result = NSMutableAttributedString(string: title.text)
        result.append(NSAttributedString(string: " "))

        let subtitle = NSMutableAttributedString(string: subtitle?.text ?? "")
        subtitle.setAttributes(
            [.foregroundColor: UIColor.secondaryLabel],
            range: NSRange(location: 0, length: subtitle.string.count)
        )
        result.append(subtitle)

        return result
    }
}
