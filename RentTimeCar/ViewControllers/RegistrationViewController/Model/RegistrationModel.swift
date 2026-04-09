//
//  RegistrationModel.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 27.02.2026.
//

import UIKit

final class RegistrationModelBox {
    var items = RegistrationModel.makeInitialStepModel()
}

enum RegistrationModel {
    case text(String)
    case image(UIImage)
}

extension RegistrationModel {
    static func makeInitialStepModel() -> [RegistrationModel] {
        [
            RegistrationModel.text(.helloText)
        ]
    }

    static func makeNeedPhotoStepModel() -> RegistrationModel {
        RegistrationModel.text(.needPhotoText)
    }

    static func makePassportInstructionModel() -> RegistrationModel {
        RegistrationModel.text(.needPassportText)
    }
}

enum RegistrationPhotoStep {
    case driverLicenseFront
    case driverLicenseBack
    case passportMain
    case passportRegistration

    var cameraLabel: String {
        switch self {
        case .driverLicenseFront: return "Лицевая сторона водительского удостоверения"
        case .driverLicenseBack: return "Обратная сторона водительского удостоверения"
        case .passportMain: return "Основная страница"
        case .passportRegistration: return "Страница с регистрацией"
        }
    }

    var next: RegistrationPhotoStep? {
        switch self {
        case .driverLicenseFront: return .driverLicenseBack
        case .driverLicenseBack: return nil
        case .passportMain: return .passportRegistration
        case .passportRegistration: return nil
        }
    }
}

private extension String {
    static let helloText = "Здравствуйте!\nПройдите регистрацию, чтобы приступить к бронированию.\n\nДля этого вам понадобится паспорт и водительское удостоверение."
    static let needPhotoText = "Сейчас сфотографируем водительское удостоверение"
    static let needPassportText = "Теперь сфотографируйте паспорт"
}
