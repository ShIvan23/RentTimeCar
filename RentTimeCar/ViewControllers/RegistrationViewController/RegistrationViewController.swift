//
//  RegistrationViewController.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 23.02.2026.
//

import UIKit
import PinLayout

final class RegistrationViewController: UIViewController {

    private enum RegistrationStep {
        case initial
        case needPhoto
        case takePhoto
    }

    // MARK: - UI

    private lazy var collectionView: UICollectionView = {
        let layout = RegistrationFlowLayout(registrationModelBox: registrationModelBox)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .mainBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cell: RegistrationTextCell.self)
        collectionView.register(cell: RegistrationImageCell.self)
        return collectionView
    }()

    private let nextStepButton = MainButton(title: "Регистрация")
    private let backButton = SecondaryButton(title: "Позже")
    private let bottomContainerView = UIView()

    // MARK: - Private Properties

    private let coordinator: ICoordinator
    private let cameraPermissionService: ICameraPermissionService
    private let registrationModelBox = RegistrationModelBox()
    private var registrationStep = RegistrationStep.initial
    private let cameraCaptureService = CameraCaptureService.shared

    // MARK: - Init

    init(
        coordinator: ICoordinator,
        cameraPermissionService: ICameraPermissionService
    ) {
        self.coordinator = coordinator
        self.cameraPermissionService = cameraPermissionService
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        performLayout()
    }

    // MARK: - Private Methods

    private func setupView() {
        view.addSubviews([collectionView, bottomContainerView])
        bottomContainerView.addSubviews([nextStepButton, backButton])
        view.backgroundColor = .mainBackground
        bottomContainerView.backgroundColor = .secondaryBackground
        collectionView.backgroundColor = .red

        backButton.action = { [weak self] in
            self?.coordinator.popViewController()
        }

        nextStepButton.action = { [weak self] in
            self?.handleNextStepAction()
        }

        cameraCaptureService.setObserver(self)
    }

    private func handleNextStepAction() {
        switch registrationStep {
        case .initial:
            registrationStep = .needPhoto
            handleNextStepAction()
        case .needPhoto:
            registrationModelBox.items.append(RegistrationModel.makeNeedPhotoStepModel())
            collectionView.reloadData()
            backButton.isHidden = true
            nextStepButton.setTitle("Сфотографировать", for: .normal)
            view.setNeedsLayout()
            registrationStep = .takePhoto
        case .takePhoto:
            cameraPermissionService.isCameraGranted { [weak self] isGranted in
                DispatchQueue.main.async {
                    if isGranted {
                        self?.coordinator.openCameraViewController()
                    } else {
                        self?.coordinator.openInfoBottomSheetViewController()
                    }
                }
            }
        }
    }

    private func performLayout() {
        var bottomContainerViewHeight: CGFloat = view.safeAreaInsets.bottom
        bottomContainerViewHeight += backButton.isHidden ? .buttonsInset + .buttonHeight : (.buttonsInset + .buttonHeight) * 2

        bottomContainerView.pin
            .bottom()
            .horizontally()
            .height(bottomContainerViewHeight)

        if !backButton.isHidden {
            backButton.pin
                .bottom()
                .horizontally()
                .height(.buttonHeight)
                .marginHorizontal(.buttonHorizontalMargin)
                .marginBottom(view.safeAreaInsets.bottom)

            nextStepButton.pin
                .above(of: backButton)
                .horizontally()
                .height(.buttonHeight)
                .marginHorizontal(.buttonHorizontalMargin)
                .marginBottom(.buttonsInset)
        } else {
            nextStepButton.pin
                .bottom()
                .horizontally()
                .height(.buttonHeight)
                .marginHorizontal(.buttonHorizontalMargin)
                .marginBottom(view.safeAreaInsets.bottom)
        }

        collectionView.pin
            .top()
            .horizontally()
            .marginTop(view.safeAreaInsets.top)
            .bottom(to: bottomContainerView.edge.top)
    }
}

// MARK: - UICollectionViewDataSource

extension RegistrationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        registrationModelBox.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let model = registrationModelBox.items[safe: indexPath.item] else { return UICollectionViewCell() }
        switch model {
        case let .image(image):
            let cell: RegistrationImageCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(with: image)
            return cell
        case let .text(text):
            let cell: RegistrationTextCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(with: text)
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension RegistrationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cell = registrationModelBox.items[safe: indexPath.item] else { return .zero }
        let cellWidth = (collectionView.bounds.width * 0.7).rounded(.down)
        switch cell {
        case let .text(text):
            let contentWidth = cellWidth - RegistrationTextCell.Constants.margin * 2
            let textSize = CGSize.textSize(for: text, maxWidth: contentWidth)
            let cellSize = CGSize(
                width: cellWidth,
                height: textSize.height + RegistrationTextCell.Constants.margin * 2
            )
            return cellSize
        case .image:
            return CGSize(square: cellWidth)
        }
    }
}

// MARK: - CameraCaptureServiceObserver

extension RegistrationViewController: CameraCaptureServiceObserver {
    func post(capturedImage: UIImage) {
        registrationModelBox.items.append(.image(capturedImage))
        collectionView.reloadData()
    }
}

private extension CGFloat {
    static let buttonHeight: CGFloat = 50
    static let buttonsInset: CGFloat = 8
    static let buttonHorizontalMargin: CGFloat = 12
}
