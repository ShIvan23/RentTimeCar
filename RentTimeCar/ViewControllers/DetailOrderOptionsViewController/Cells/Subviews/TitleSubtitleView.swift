//
//  TitleSubtitleView.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 11.12.2025.
//

import UIKit

protocol TitleSubtitleViewDelegate: AnyObject {
    func didTapInfo(for cellType: DetailOrderOptionModel.CellType)
}

final class TitleSubtitleView: UIView {
    // MARK: - UI

    private let title = Label(
        numberOfLines: 1,
        fontSize: 14,
        textAlignment: .left
    )
    private let subtitle = Label(
        numberOfLines: 1,
        fontSize: 12,
        textColor: .secondaryTextColor,
        textAlignment: .left
    )
    private let infoImageContainer = UIView()
    private let infoImageView = UIImageView()

    // MARK: - Private Properties

    private var cellType: DetailOrderOptionModel.CellType?
    private weak var delegate: TitleSubtitleViewDelegate?

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
        autoSizeThatFits(size, layoutClosure: performLayout)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        performLayout()
    }

    // MARK: - Internal Methods

    func configure(
        title: String,
        subtitle: String,
        cellType: DetailOrderOptionModel.CellType,
        delegate: TitleSubtitleViewDelegate
    ) {
        self.title.text = title
        self.subtitle.text = subtitle
        self.cellType = cellType
        self.delegate = delegate
    }

    // MARK: - Private Methods

    private func setupView() {
        addSubviews([title, subtitle, infoImageContainer])
        infoImageContainer.addSubview(infoImageView)
        infoImageView.image = .info.withRenderingMode(.alwaysTemplate)
        infoImageView.tintColor = .whiteTextColor
        infoImageContainer.addTapGestureClosure { [weak self] in
            guard let self,
            let cellType else { return}
            delegate?.didTapInfo(for: cellType)
        }
    }

    private func performLayout() {
        title.pin
            .topLeft()
            .sizeToFit()

        subtitle.pin
            .below(of: title, aligned: .left)
            .sizeToFit()

        infoImageContainer.pin
            .after(of: title, aligned: .center)
            .size(CGSize(square: 30))

        infoImageView.pin
            .center()
            .size(CGSize(square: 16))
    }
}
