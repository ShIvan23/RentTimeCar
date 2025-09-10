//
//  SideMenuModel.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 01.08.2025.
//

import UIKit

struct SideMenuModel {
    let image: UIImage?
    let title: String
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
    static func makeModels() -> [[SideMenuModel]] {
        [
            [
                SideMenuModel(
                    image: .car,
                    title: "Мои аренды",
                    subtitle: "История всех ваших аренд",
                    cellType: .small
                ),
                SideMenuModel(
                    image: .file,
                    title: "Мои штрафы",
                    subtitle: "Оплата и детали штрафов ГИБДД",
                    cellType: .small
                ),
                SideMenuModel(
                    image: .setting,
                    title: "Мои настройки",
                    subtitle: nil,
                    cellType: .small
                )
            ],
            [
                SideMenuModel(
                    image: .mercedesBenz,
                    title: "Каталог",
                    subtitle: "Более 40 автомобилей",
                    cellType: .big
                ),
                SideMenuModel(
                    image: .support,
                    title: "Поддержка",
                    subtitle: "На связи с Вами 24/7",
                    cellType: .big
                ),
            ]
        ]
    }
}
