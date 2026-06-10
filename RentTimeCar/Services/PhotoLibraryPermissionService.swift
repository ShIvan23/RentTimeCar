//
//  PhotoLibraryPermissionService.swift
//  RentTimeCar
//

import Photos

protocol IPhotoLibraryPermissionService {
    func isPhotoLibraryGranted(completion: @escaping (Bool) -> Void)
}

final class PhotoLibraryPermissionService: IPhotoLibraryPermissionService {

    func isPhotoLibraryGranted(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }
        case .restricted, .denied:
            completion(false)
        case .authorized, .limited:
            completion(true)
        @unknown default:
            completion(false)
        }
    }
}
