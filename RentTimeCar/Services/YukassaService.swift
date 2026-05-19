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
    static let prepayAmount = 1

    // MARK: - Private Configuration

    private let baseURL = "https://rent-time-car.ru"

    // MARK: - Init

    private init() {}

    // MARK: - Public Methods

    /// Формирует URLRequest для создания платежа через собственный бэкенд.
    /// Бэкенд хранит ключи ЮKassa и сам обращается к api.yookassa.ru.
    /// Выполнение запроса делегируется в RentApiFacade → NetworkManager.
    func makeCreatePaymentRequest(input: YookassaPaymentInput) -> URLRequest? {
        guard let url = URL(string: baseURL + "/api/payments/yookassa/create") else {
            assertionFailure("Invalid URL: \(baseURL)/api/payments/yookassa/create")
            return nil
        }
        guard let body = try? JSONEncoder().encode(input) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        return request
    }

    func makePaymentStatusRequest(paymentId: String) -> URLRequest? {
        guard let url = URL(string: baseURL + "/api/payments/status") else {
            assertionFailure("Invalid URL: \(baseURL)/api/payments/status")
            return nil
        }
        guard let body = try? JSONEncoder().encode(["paymentId": paymentId]) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        return request
    }
}

// MARK: - Request body

struct YookassaPaymentInput: Encodable {
    let amount: Int
    let description: String
    let phone: String
}

// MARK: - Response models

struct YookassaPaymentResponse: Decodable {
    let confirmationUrl: String
    let paymentId: String
}

struct PaymentStatusResponse: Decodable {
    let status: PaymentStatus
}

enum PaymentStatus: String, Decodable {
    case pending
    case succeeded
    case canceled
}

// MARK: - Errors

enum YukassaError: LocalizedError {
    case missingConfirmationURL

    var errorDescription: String? {
        "Не получен URL страницы оплаты от сервера."
    }
}
