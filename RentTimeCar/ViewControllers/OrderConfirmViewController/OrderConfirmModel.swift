//
//  OrderConfirmModel.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 08.01.2026.
//

import Foundation

enum OrderConfirmModel {
    case image(OrderConfirmImage)
    case text(OrderConfirmText)
}

extension OrderConfirmModel {
    struct OrderConfirmImage {
        let imageUrl: String
    }

    struct OrderConfirmText {
        let title: String
        let subtitle: String
    }
}

extension OrderConfirmModel {
    static func makeModel() -> [OrderConfirmModel] {
        let orderConfirmService = OrderConfirmService.shared
        var result = [OrderConfirmModel]()
        result.append(
            .image(
                OrderConfirmImage(
                    imageUrl: orderConfirmService.imageUrl
                )
            )
        )
        result.append(
            .text(
                OrderConfirmText(
                    title: "Дата аренды",
                    subtitle: orderConfirmService.selectedDates
                )
            )
        )
        result.append(
            .text(
                OrderConfirmText(
                    title: "Доставка",
                    subtitle: orderConfirmService.deliveryAddress
                )
            )
        )
        result.append(
            .text(
                OrderConfirmText(
                    title: "Возврат",
                    subtitle: orderConfirmService.returnAddress
                )
            )
        )
        let optionsText = orderConfirmService.selectedOptions.joined(separator: ", ")
        if !optionsText.isEmpty {
            result.append(
                .text(
                    OrderConfirmText(
                        title: "Дополнительные опции",
                        subtitle: optionsText
                    )
                )
            )
        }
        return result
    }
}
