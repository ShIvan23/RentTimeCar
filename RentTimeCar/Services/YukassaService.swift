//
//  YukassaService.swift
//  RentTimeCar
//

import Foundation

final class YukassaService {

    // MARK: - Public Properties

    static let shared = YukassaService()

    // ЮKassa перенаправляет на return_url после завершения оплаты.
    static let returnURL = "https://renttimecar.ru/payment/success"
    static let failURL   = "https://renttimecar.ru/payment/fail"

    // MARK: - Private Configuration

    private let baseURL = "https://renttimecarapi-production.up.railway.app"

    // MARK: - Init

    private init() {}

    // MARK: - Public Methods

    /// Формирует URLRequest для создания платежа через собственный бэкенд.
    /// Бэкенд хранит ключи ЮKassa и сам обращается к api.yookassa.ru.
    /// Выполнение запроса делегируется в RentApiFacade → NetworkManager.
    func makeCreatePaymentRequest(amount: Int, description: String) -> URLRequest? {
        guard let url = URL(string: baseURL + "/api/payments/yukassa/create") else {
            assertionFailure("Invalid URL: \(baseURL)/api/payments/yukassa/create")
            return nil
        }
        guard let body = try? JSONEncoder().encode(YukassaCreatePaymentBody(amount: amount, description: description)) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        return request
    }
}

// MARK: - Request body

private struct YukassaCreatePaymentBody: Encodable {
    let amount: Int
    let description: String
}

// MARK: - Response model

struct YukassaCreatePaymentResponse: Decodable {
    let confirmationUrl: String
}

// MARK: - Errors

enum YukassaError: LocalizedError {
    case missingConfirmationURL

    var errorDescription: String? {
        "Не получен URL страницы оплаты от сервера."
    }
}
