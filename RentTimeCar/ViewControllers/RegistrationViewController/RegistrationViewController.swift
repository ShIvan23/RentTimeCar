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
        case takeDriverLicense
        case licenseDone
        case readyToSubmit
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

    // MARK: - Upload Overlay UI

    private lazy var uploadOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        view.isHidden = true
        return view
    }()

    private let uploadActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        return indicator
    }()

    private let uploadProgressLabel = Label(
        fontSize: 18,
        textColor: .whiteTextColor,
        textAlignment: .center
    )

    private let uploadWarningLabel = Label(
        text: "Дождитесь, пока фото загрузятся. Не выходите с этого экрана и не сворачивайте приложение",
        numberOfLines: 0,
        fontSize: 14,
        textColor: .whiteTextColor,
        textAlignment: .center
    )

    // MARK: - Private Properties

    private let coordinator: ICoordinator
    private let cameraPermissionService: ICameraPermissionService
    private let rentApiFacade: RentApiFacade
    private let registrationModelBox = RegistrationModelBox()
    private var registrationStep = RegistrationStep.initial
    private let cameraCaptureService = CameraCaptureService.shared
    private let authService = AuthService.shared

    // MARK: - Init

    init(
        coordinator: ICoordinator,
        cameraPermissionService: ICameraPermissionService,
        rentApiFacade: RentApiFacade
    ) {
        self.coordinator = coordinator
        self.cameraPermissionService = cameraPermissionService
        self.rentApiFacade = rentApiFacade
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollToBottom()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        performLayout()
    }

    // MARK: - Private Methods

    private func setupView() {
        view.addSubviews([collectionView, bottomContainerView, uploadOverlayView])
        bottomContainerView.addSubviews([nextStepButton, backButton])
        uploadOverlayView.addSubviews([uploadActivityIndicator, uploadProgressLabel, uploadWarningLabel])
        view.backgroundColor = .mainBackground
        bottomContainerView.backgroundColor = .secondaryBackground

        backButton.action = { [weak self] in
            self?.coordinator.popViewController()
        }

        nextStepButton.action = { [weak self] in
            self?.handleNextStepAction()
        }

        cameraCaptureService.setObserver(self)
    }
    
    private func scrollToBottom() {
        let lastIndex = registrationModelBox.items.count - 1
        guard lastIndex >= 0 else { return }
        collectionView.scrollToItem(
            at: IndexPath(item: lastIndex, section: 0),
            at: .bottom,
            animated: true
        )
    }

    private func handleNextStepAction() {
        switch registrationStep {
        case .initial:
            registrationModelBox.items.append(RegistrationModel.makeNeedPhotoStepModel())
            collectionView.reloadData()
            backButton.isHidden = true
            nextStepButton.setTitle("Сфотографировать", for: .normal)
            view.setNeedsLayout()
            registrationStep = .takeDriverLicense
        case .takeDriverLicense:
            openCamera(for: .driverLicenseFront)
        case .licenseDone:
            openCamera(for: .passportMain)
        case .readyToSubmit:
            uploadPhotos()
        }
    }

    private func openCamera(for step: RegistrationPhotoStep) {
        cameraPermissionService.isCameraGranted { [weak self] isGranted in
            DispatchQueue.main.async {
                if isGranted {
                    self?.coordinator.openCameraViewController(photoStep: step)
                } else {
                    self?.coordinator.openInfoBottomSheetViewController()
                }
            }
        }
    }

    private func uploadPhotos() {
        guard let clientIntegrationId = authService.client?.integrationId else { return }
        let images = registrationModelBox.items.compactMap { item -> UIImage? in
            if case let .image(image) = item { return image }
            return nil
        }
        showUploadOverlay()
        rentApiFacade.uploadImages(images, clientIntegrationId: clientIntegrationId, onProgress: { [weak self] progress in
            self?.updateUploadProgress(progress)
        }, completion: { [weak self] result in
            DispatchQueue.main.async {
                self?.hideUploadOverlay()
                switch result {
                case .success:
                    self?.authService.saveState(authState: .onCheck)
                    self?.coordinator.popToRootViewController()
                case .failure(let error):
                    self?.showUploadError(error)
                }
            }
        })
    }

    private func showUploadOverlay() {
        uploadProgressLabel.text = "Загрузка: 0%"
        uploadOverlayView.isHidden = false
        uploadActivityIndicator.startAnimating()
        view.setNeedsLayout()
    }

    private func hideUploadOverlay() {
        uploadOverlayView.isHidden = true
        uploadActivityIndicator.stopAnimating()
    }

    private func updateUploadProgress(_ progress: Double) {
        let percentage = Int(progress * 100)
        uploadProgressLabel.text = "Загрузка: \(percentage)%"
    }

    private func showUploadError(_ error: Error) {
        let alert = UIAlertController(
            title: "Ошибка загрузки",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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

        layoutUploadOverlay()
    }

    private func layoutUploadOverlay() {
        uploadOverlayView.pin.all()

        let centerY = view.bounds.midY
        let labelWidth = view.bounds.width - 64

        uploadActivityIndicator.pin
            .hCenter()
            .top(centerY - 80)
            .sizeToFit()

        let progressHeight = uploadProgressLabel.sizeThatFits(
            CGSize(width: labelWidth, height: .greatestFiniteMagnitude)
        ).height
        uploadProgressLabel.pin
            .below(of: uploadActivityIndicator)
            .horizontally(32)
            .height(progressHeight)
            .marginTop(20)

        let warningHeight = uploadWarningLabel.sizeThatFits(
            CGSize(width: labelWidth, height: .greatestFiniteMagnitude)
        ).height
        uploadWarningLabel.pin
            .below(of: uploadProgressLabel)
            .horizontally(32)
            .height(warningHeight)
            .marginTop(20)
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

        let imageCount = registrationModelBox.items.filter {
            if case .image = $0 { return true }
            return false
        }.count

        switch imageCount {
        case 2:
            registrationModelBox.items.append(RegistrationModel.makePassportInstructionModel())
            collectionView.reloadData()
            registrationStep = .licenseDone
            nextStepButton.setTitle("Сфотографировать", for: .normal)
        case 4:
            registrationStep = .readyToSubmit
            nextStepButton.setTitle("Отправить фото", for: .normal)
        default:
            break
        }

        view.setNeedsLayout()
    }
}

private extension CGFloat {
    static let buttonHeight: CGFloat = 50
    static let buttonsInset: CGFloat = 8
    static let buttonHorizontalMargin: CGFloat = 12
}
