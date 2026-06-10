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
        [RegistrationModel.text(.helloText)]
    }

    static func makeDriverLicenseFrontInstructionModel() -> RegistrationModel {
        .text(.driverLicenseFrontText)
    }

    static func makeDriverLicenseBackInstructionModel() -> RegistrationModel {
        .text(.driverLicenseBackText)
    }

    static func makePassportMainInstructionModel() -> RegistrationModel {
        .text(.passportMainText)
    }

    static func makePassportRegistrationInstructionModel() -> RegistrationModel {
        .text(.passportRegistrationText)
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
    static let driverLicenseFrontText = "Сделайте фото лицевой стороны водительского удостоверения"
    static let driverLicenseBackText  = "Теперь сделайте фото обратной стороны водительского удостоверения"
    static let passportMainText       = "Теперь сфотографируйте основную страницу паспорта"
    static let passportRegistrationText = "Теперь сфотографируйте страницу паспорта с регистрацией"
}
