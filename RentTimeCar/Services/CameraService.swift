//
//  CameraService.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 03.03.2026.
//

import UIKit
import AVFoundation

protocol CameraServiceDelegate: AnyObject {
    func cameraService(_ service: CameraService, didCapture image: UIImage)
    func cameraService(_ service: CameraService, didFailWith error: Error)
}

class CameraService: NSObject {

    // MARK: - Properties

    weak var delegate: CameraServiceDelegate?
    private var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var currentCameraPosition: AVCaptureDevice.Position = .back

    // MARK: - Public Methods

    func setupCamera(in view: UIView) throws {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .photo

        // Настройка устройства камеры
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition) else {
            throw CameraError.cannotCaptureInput
        }

        do {
            // Создаем вход для камеры
            let input = try AVCaptureDeviceInput(device: camera)

            // Добавляем вход в сессию
            if let session = captureSession, session.canAddInput(input) {
                session.addInput(input)
            }

            // Настраиваем вывод для фото
            photoOutput = AVCapturePhotoOutput()
            if let output = photoOutput, let session = captureSession, session.canAddOutput(output) {
                session.addOutput(output)
            }

            // Настраиваем слой предпросмотра
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            previewLayer?.videoGravity = .resizeAspectFill
            previewLayer?.frame = view.bounds
            view.layer.insertSublayer(previewLayer!, at: 0)

            // Запускаем сессию
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession?.startRunning()
            }

        } catch {
            throw CameraError.setupFailed(error)
        }
    }

    func capturePhoto() {
        guard let photoOutput = photoOutput else {
            delegate?.cameraService(self, didFailWith: CameraError.photoOutputNotReady)
            return
        }

        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto

        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func switchCamera() throws {
        guard let captureSession = captureSession else {
            throw CameraError.sessionNotRunning
        }

        // Убираем текущий вход
        captureSession.beginConfiguration()

        if let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput {
            captureSession.removeInput(currentInput)
        }

        // Меняем позицию камеры
        currentCameraPosition = currentCameraPosition == .back ? .front : .back

        // Добавляем новый вход
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition) else {
            throw CameraError.cannotCaptureInput
        }

        do {
            let newInput = try AVCaptureDeviceInput(device: camera)
            captureSession.addInput(newInput)
            captureSession.commitConfiguration()
        } catch {
            throw CameraError.cannotSwitchCamera
        }
    }

    func stopSession() {
        captureSession?.stopRunning()
    }

    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession?.startRunning()
        }
    }

    func updatePreviewLayer(frame: CGRect) {
        previewLayer?.frame = frame
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            delegate?.cameraService(self, didFailWith: error)
            return
        }

        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            delegate?.cameraService(self, didFailWith: CameraError.cannotCaptureImage)
            return
        }

        // Корректируем ориентацию изображения
        let orientedImage = fixImageOrientation(image)
        delegate?.cameraService(self, didCapture: orientedImage)
    }

    private func fixImageOrientation(_ image: UIImage) -> UIImage {
        if image.imageOrientation == .up {
            return image
        }

        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return normalizedImage ?? image
    }
}

// MARK: - Обработка ошибок

enum CameraError: Error, LocalizedError {
    case cannotCaptureInput
    case setupFailed(Error)
    case photoOutputNotReady
    case cannotCaptureImage
    case sessionNotRunning
    case cannotSwitchCamera

    var errorDescription: String? {
        switch self {
        case .cannotCaptureInput:
            return "Не удалось получить доступ к камере"
        case .setupFailed(let error):
            return "Ошибка настройки камеры: \(error.localizedDescription)"
        case .photoOutputNotReady:
            return "Фото вывод не готов"
        case .cannotCaptureImage:
            return "Не удалось захватить изображение"
        case .sessionNotRunning:
            return "Сессия камеры не запущена"
        case .cannotSwitchCamera:
            return "Не удалось переключить камеру"
        }
    }
}
