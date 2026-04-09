//
//  CameraCaptureService.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 03.03.2026.
//

import UIKit

protocol CameraCaptureServiceObserver: AnyObject {
    func post(capturedImage: UIImage)
}

final class CameraCaptureService {
    static let shared = CameraCaptureService()

    private weak var observer: CameraCaptureServiceObserver?
    var pendingNextPhotoStep: RegistrationPhotoStep?

    private init() {}

    func setObserver(_ observer: CameraCaptureServiceObserver?) {
        self.observer = observer
    }

    func setImage(_ image: UIImage) {
        observer?.post(capturedImage: image)
    }
}
