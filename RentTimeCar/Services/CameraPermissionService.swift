//
//  CameraPermissionService.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 28.02.2026.
//

import AVFoundation

protocol ICameraPermissionService {
    func isCameraGranted(completion: @escaping (Bool) -> Void)
}

final class CameraPermissionService: ICameraPermissionService {

    // MARK: - Internal Methods

    func isCameraGranted(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { isGranted in
                DispatchQueue.main.async {
                    completion(isGranted)
                }
            }
        case .restricted, .denied:
            completion(false)
        case .authorized:
            completion(true)
        @unknown default:
            completion(false)
        }
    }
}
