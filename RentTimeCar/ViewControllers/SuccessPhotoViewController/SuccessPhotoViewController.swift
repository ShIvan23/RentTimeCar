//
//  SuccessPhotoViewController.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 28.02.2026.
//

import UIKit

protocol SuccessPhotoViewControllerDelegate: AnyObject {
    func handleCapturedImage(_ image: UIImage)
}

final class SuccessPhotoViewController: UIViewController {

    // MARK: - UI

    private lazy var successPhotoView = SuccessPhotoView(delegate: self)

    // MARK: - Private Properties

    private let coordinator: ICoordinator
    private let photoStep: RegistrationPhotoStep
    private let cameraCaptureService = CameraCaptureService.shared

    init(
        coordinator: ICoordinator,
        image: UIImage,
        photoStep: RegistrationPhotoStep
    ) {
        self.coordinator = coordinator
        self.photoStep = photoStep
        super.init(nibName: nil, bundle: nil)
        successPhotoView.configure(with: image)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func loadView() {
        view = successPhotoView
    }
}

// MARK: - SuccessPhotoViewDelegate

extension SuccessPhotoViewController: SuccessPhotoViewDelegate {
    func didTapRetry() {
        coordinator.popViewController()
    }

    func didTapConfirm(image: UIImage) {
        cameraCaptureService.setImage(image)
        if let nextStep = photoStep.next {
            cameraCaptureService.pendingNextPhotoStep = nextStep
            coordinator.popViewController()
        } else {
            coordinator.popToViewController(.registration)
        }
    }
}
