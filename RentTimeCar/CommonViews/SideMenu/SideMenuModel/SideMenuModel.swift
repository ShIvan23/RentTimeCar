//
//  SideMenuModel.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 01.08.2025.
//

import UIKit

struct SideMenuModel {
    let image: UIImage?
    let title: SideMenuModelNaming
    let subtitle: String?
    let cellType: SideMenuCellType
    let backgroundColor: UIColor = .secondaryBackground
    let hasArrow: Bool = true
}

enum SideMenuCellType {
    case small
    case big
}

extension SideMenuModel {
    static func makeModels(isAuthorized: Bool) -> [[SideMenuModel]] {
        var result = [[SideMenuModel]]()
        if isAuthorized {
            result.append(
                [
                    SideMenuModel(
                        image: .car,
                        title: SideMenuModelNaming.myRents,
                        subtitle: "История всех ваших аренд",
                        cellType: .small
                    ),
                    SideMenuModel(
                        image: .file,
                        title: SideMenuModelNaming.myFines,
                        subtitle: "Оплата и детали штрафов ГИБДД",
                        cellType: .small
                    )
//                    SideMenuModel(
//                        image: .setting,
//                        title: SideMenuModelNaming.mySettings,
//                        subtitle: nil,
//                        cellType: .small
//                    )
                ]
            )
        }

        result.append(
            [
                SideMenuModel(
                    image: .mercedesBenz,
                    title: SideMenuModelNaming.catalog,
                    subtitle: "Более 40 автомобилей",
                    cellType: .big
                ),
                SideMenuModel(
                    image: .support,
                    title: SideMenuModelNaming.support,
                    subtitle: "На связи с Вами 24/7",
                    cellType: .big
                ),
            ]
        )
        return result
    }
}

enum SideMenuModelNaming: String {
    case myRents = "Мои аренды"
    case myFines = "Мои штрафы"
    case mySettings = "Мои настройки"
    case catalog = "Каталог"
    case support = "Поддержка"
}
