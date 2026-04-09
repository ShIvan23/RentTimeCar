//
//  SuccessPhotoView.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 28.02.2026.
//

import UIKit

protocol SuccessPhotoViewDelegate: AnyObject {
    func didTapRetry()
    func didTapConfirm(image: UIImage)
}

final class SuccessPhotoView: UIView {
    // MARK: - UI

    private let capturedImageView = UIImageView()
    private let titleLabel = Label(
        text: "Фото хорошее?",
        textAlignment: .left
    )
    private let subtitleLabel = Label(
        text: "Фото должно быть видно полностью, четко и без бликов",
        textAlignment: .left
    )
    private let retryButton = SecondaryButton(title: "Переснять")
    private let confirmButton = MainButton(title: "Сохранить")

    // MARK: - Private Properties

    private weak var delegate: SuccessPhotoViewDelegate?

    // MARK: - Init

    init(delegate: SuccessPhotoViewDelegate?) {
        self.delegate = delegate
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override public func layoutSubviews() {
        super.layoutSubviews()
        performLayout()
    }

    // MARK: - Internal Methods

    func configure(with image: UIImage) {
        capturedImageView.image = image
    }

    // MARK: - Private Methods

    private func setupView() {
        backgroundColor = .mainBackground
        addSubviews([capturedImageView, titleLabel, subtitleLabel, retryButton, confirmButton])
        capturedImageView.clipsToBounds = true
        capturedImageView.contentMode = .scaleAspectFill

        retryButton.action = { [weak self] in
            self?.delegate?.didTapRetry()
        }

        confirmButton.action = { [weak self] in
            guard let self,
            let image = capturedImageView.image else { return }
            delegate?.didTapConfirm(image: image)
        }
    }

    private func performLayout() {
        capturedImageView.pin
            .top(safeAreaInsets.top)
            .horizontally()
            .height(bounds.width)

        let buttonWidth = (bounds.width - .buttonHorizontalMargin * 2 - .buttonsBetweenInset) / 2

        retryButton.pin
            .bottomLeft()
            .width(buttonWidth)
            .marginLeft(.buttonHorizontalMargin)
            .marginBottom(safeAreaInsets.bottom + 16)
            .height(.buttonHeight)

        confirmButton.pin
            .after(of: retryButton, aligned: .top)
            .marginLeft(.buttonsBetweenInset)
            .width(buttonWidth)
            .height(.buttonHeight)

        subtitleLabel.pin
            .above(of: retryButton)
            .horizontally()
            .marginBottom(30)
            .marginHorizontal(.textHorizontalMargin)
            .sizeToFit(.width)

        titleLabel.pin
            .above(of: subtitleLabel)
            .horizontally()
            .marginBottom(14)
            .marginHorizontal(.textHorizontalMargin)
            .sizeToFit(.width)
    }
}

private extension CGFloat {
    static let buttonHorizontalMargin: CGFloat = 12
    static let buttonsBetweenInset: CGFloat = 16
    static let textHorizontalMargin: CGFloat = 12
    static let buttonHeight: CGFloat = 50
}
