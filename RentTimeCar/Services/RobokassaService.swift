//
//  RobokassaService.swift
//  RentTimeCar
//

import Foundation
import CryptoKit

final class RobokassaService {

    // MARK: - Public Properties
    static let shared = RobokassaService()

    // Robokassa перенаправляет сюда после успешной / неуспешной оплаты.
    // Зарегистрируйте эти же URL в личном кабинете Robokassa (SuccessURL / FailURL).
    static let successURL = "https://renttimecar.ru/payment/success"
    static let failURL    = "https://renttimecar.ru/payment/fail"

    // MARK: - Private Configuration
    // ⚠️ Замените значения на реальные из личного кабинета Robokassa.
    // В продакшене Password1/Password2 лучше хранить на сервере, а URL запрашивать через API.
    private let merchantLogin = "YOUR_MERCHANT_LOGIN"
    private let password1     = "YOUR_PASSWORD_1"
    private let isTestMode    = true   // false в продакшене

    private let baseURL = "https://auth.robokassa.ru/Merchant/Index.aspx"

    // MARK: - Init
    private init() {}

    // MARK: - Public Methods

    /// Генерирует уникальный номер счёта (InvId).
    /// В продакшене рекомендуется генерировать InvId на сервере и хранить в БД.
    func generateInvId() -> Int {
        Int(Date().timeIntervalSince1970)
    }

    /// Строит URL для открытия страницы оплаты Robokassa.
    /// - Parameters:
    ///   - amount:      Сумма оплаты в рублях (целое число).
    ///   - invId:       Номер счёта (уникальный для каждого платежа).
    ///   - description: Описание платежа (отображается покупателю).
    /// - Returns: Готовый URL или `nil`, если параметры некорректны.
    func buildPaymentURL(amount: Int, invId: Int, description: String) -> URL? {
        let outSum = formatAmount(amount)
        let signature = md5("\(merchantLogin):\(outSum):\(invId):\(password1)")

        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "MerchantLogin",   value: merchantLogin),
            URLQueryItem(name: "OutSum",           value: outSum),
            URLQueryItem(name: "InvId",            value: "\(invId)"),
            URLQueryItem(name: "Description",      value: description),
            URLQueryItem(name: "SignatureValue",   value: signature),
            URLQueryItem(name: "Culture",          value: "ru"),
            URLQueryItem(name: "Encoding",         value: "utf-8"),
        ]
        if isTestMode {
            components?.queryItems?.append(URLQueryItem(name: "IsTest", value: "1"))
        }
        return components?.url
    }

    // MARK: - Private Methods

    /// Форматирует сумму как "5000.00" (формат, требуемый Robokassa).
    private func formatAmount(_ amount: Int) -> String {
        String(format: "%.2f", Double(amount))
    }

    /// Вычисляет MD5-подпись (требуется Robokassa).
    private func md5(_ string: String) -> String {
        let data = Data(string.utf8)
        let hash = Insecure.MD5.hash(data: data)
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
}
