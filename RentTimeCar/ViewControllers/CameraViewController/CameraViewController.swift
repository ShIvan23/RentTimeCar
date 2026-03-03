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
    private let generator = UIImpactFeedbackGenerator(style: .light)
    private let cameraService = CameraService()
    private var capturingInProgress = false

    // MARK: - UI

    private let previewView = UIView()
    private lazy var captureImageButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.tintColor = .white
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        return button
    }()

    // MARK: - Init

    init(coordinator: ICoordinator) {
        self.coordinator = coordinator
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
        setupCamera()
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
        view.addSubviews([previewView, captureImageButton])
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
        previewView.pin
            .top(view.safeAreaInsets.top)
            .horizontally()
            .height(view.bounds.width)

        captureImageButton.pin
            .bottom()
            .size(.buttonSize)
            .hCenter()
            .marginBottom(view.safeAreaInsets.bottom)
    }
}

// MARK: -

extension CameraViewController: CameraServiceDelegate {
    func cameraService(_ service: CameraService, didCapture image: UIImage) {
           // Обрабатываем захваченное изображение
        guard capturingInProgress else { return }
        capturingInProgress = false
        coordinator.openSuccessPhotoViewController(image: image)
        captureImageButton.isEnabled = true
       }

       func cameraService(_ service: CameraService, didFailWith error: Error) {
           showError(error)
       }
}


private extension CGSize {
    static let buttonSize = CGSize(square: 50)
}
