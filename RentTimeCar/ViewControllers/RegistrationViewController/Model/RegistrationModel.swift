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
}

private extension String {
    static let helloText = "Здравствуйте!\nПройдите регистрацию, чтобы приступить к бронированию.\n\nДля этого вам понадобится паспорт и водительское удостоверение."
    static let needPhotoText = "Сейчас сфотографируем водительское удостоверение"
}
