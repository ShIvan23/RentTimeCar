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
                print("isGranted = \(isGranted)")
                if !isGranted {
                    // надо показывать что-то? что теперь только через настройки
                }
                completion(isGranted)
            }
        case .restricted:
            assertionFailure("restricted permission")
            completion(false)
        case .denied:
            // нужно показать экран с переправкой в настройки
            completion(false)
        case .authorized:
            completion(true)
        @unknown default:
            assertionFailure("restricted permission")
            completion(false)
        }
    }
}
