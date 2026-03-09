//
//  CameraViewController.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 28.02.2026.
//

import UIKit
import AVFoundation

final class CameraViewController: UIViewController {

    // MARK: - Private Properties

    private let coordinator: ICoordinator
    private var photoStep: RegistrationPhotoStep
    private let generator = UIImpactFeedbackGenerator(style: .light)
    private let cameraService = CameraService()
    private var capturingInProgress = false
    private var isCameraSetup = false

    // MARK: - UI

    private let previewView = UIView()
    private lazy var instructionLabel = Label(
        text: photoStep.cameraLabel,
        numberOfLines: 0,
        textAlignment: .center
    )
    private lazy var captureImageButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.tintColor = .white
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        return button
    }()

    // MARK: - Init

    init(coordinator: ICoordinator, photoStep: RegistrationPhotoStep) {
        self.coordinator = coordinator
        self.photoStep = photoStep
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
        guard !isMovingToParent else { return }
        let captureService = CameraCaptureService.shared
        if let nextStep = captureService.pendingNextPhotoStep {
            captureService.pendingNextPhotoStep = nil
            photoStep = nextStep
            instructionLabel.text = nextStep.cameraLabel
            view.setNeedsLayout()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        performLayout()
        if !isCameraSetup {
            isCameraSetup = true
            setupCamera()
        } else {
            cameraService.updatePreviewLayer(frame: previewView.bounds)
        }
    }

    deinit {
        cameraService.stopSession()
    }

    // MARK: - Private Methods

    @objc private func buttonAction() {
        captureImageButton.isEnabled = false
        capturingInProgress = true
        generator.impactOccurred()
        cameraService.capturePhoto()
    }

    private func setupCamera() {
        cameraService.delegate = self

        do {
            try cameraService.setupCamera(in: previewView)
        } catch {
            showError(error)
        }
    }

    private func setupView() {
        view.backgroundColor = .mainBackground
        view.addSubviews([previewView, instructionLabel, captureImageButton])
        previewView.backgroundColor = .mainBackground
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func performLayout() {
        let labelWidth = view.bounds.width - 32
        let labelHeight = instructionLabel.sizeThatFits(
            CGSize(width: labelWidth, height: .greatestFiniteMagnitude)
        ).height

        instructionLabel.pin
            .top(view.safeAreaInsets.top + 16)
            .horizontally(16)
            .height(labelHeight)

        previewView.pin
            .below(of: instructionLabel)
            .horizontally()
            .height(view.bounds.width)
            .marginTop(8)

        captureImageButton.pin
            .bottom()
            .size(.buttonSize)
            .hCenter()
            .marginBottom(view.safeAreaInsets.bottom)
    }
}

// MARK: - CameraServiceDelegate

extension CameraViewController: CameraServiceDelegate {
    func cameraService(_ service: CameraService, didCapture image: UIImage) {
        guard capturingInProgress else { return }
        capturingInProgress = false
        coordinator.openSuccessPhotoViewController(image: image, photoStep: photoStep)
        captureImageButton.isEnabled = true
    }

    func cameraService(_ service: CameraService, didFailWith error: Error) {
        showError(error)
    }
}

private extension CGSize {
    static let buttonSize = CGSize(square: 50)
}
