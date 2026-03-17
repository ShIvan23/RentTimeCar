//
//  RequestManagerV2.swift
//  RentTimeCar
//
//  Created by Ivan on 08.03.2026.
//

import Foundation
import UIKit

final class RequestManagerV2 {
    enum Method: String {
        case get = "GET"
        case post = "POST"
    }

    private let baseURL = "https://renttimecarapi-production.up.railway.app"
    private let baseHeader = ["content-type": "application/json"]
    private let encoder = JSONEncoder()

    // MARK: - POST /api/clients/get

    func getClients(with phoneNumber: String) -> URLRequest? {
        makeRequest(
            path: "/api/clients/get",
            method: .post,
            body: PhoneBody(phoneNumber: phoneNumber)
        )
    }

    // MARK: - GET /api/autos

    func getAutos() -> URLRequest? {
        makeRequest(path: "/api/autos", method: .get)
    }

    // MARK: - POST /api/clients/add

    func addClient(with phoneNumber: String) -> URLRequest? {
        makeRequest(
            path: "/api/clients/add",
            method: .post,
            body: PhoneBody(phoneNumber: phoneNumber)
        )
    }

    // MARK: - POST /api/autos/search

    func searchAuto(with input: SearchAutoInput) -> URLRequest? {
        // Vapor-сервер ожидает camelCase, тогда как SearchAutoInput использует
        // uppercase CodingKeys (DateFrom, Brands...) для внешнего API.
        // Поэтому конвертируем через промежуточную структуру.
        let body = VaporSearchAutoBody(
            dateFrom: input.dateFrom,
            dateTo: input.dateTo,
            brands: input.brands,
            defaultPriceFrom: input.defaultPriceFrom,
            defaultPriceTo: input.defaultPriceTo,
            autoClasses: input.autoClasses,
            powerMin: input.powerMin,
            powerMax: input.powerMax
        )
        return makeRequest(path: "/api/autos/search", method: .post, body: body)
    }

    // MARK: - GET /api/filters

    func getFiltersParams() -> URLRequest? {
        makeRequest(path: "/api/filters", method: .get)
    }

    // MARK: - POST /api/upload-images

    /// Возвращает URLRequest и тело запроса отдельно — необходимо для uploadTask.
    func uploadImages(_ images: [UIImage]) -> (request: URLRequest, body: Data)? {
        let base64Strings = images.compactMap {
            $0.resized(maxDimension: 1024).jpegData(compressionQuality: 0.7)?.base64EncodedString()
        }
        guard !base64Strings.isEmpty else { return nil }
        guard let url = URL(string: baseURL + "/api/upload-images") else {
            assertionFailure("Invalid URL: \(baseURL)/api/upload-images")
            return nil
        }
        guard let body = try? encoder.encode(UploadImagesBody(images: base64Strings)) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = Method.post.rawValue
        request.allHTTPHeaderFields = baseHeader
        return (request, body)
    }

    // MARK: - POST /api/requests/add

    func addRequest(with input: AddRequestInput) -> URLRequest? {
        makeRequest(path: "/api/requests/add", method: .post, body: input)
    }

    // MARK: - POST /api/requests/get

    func getClientRequests(clientIntegrationId: String) -> URLRequest? {
        makeRequest(
            path: "/api/requests/get",
            method: .post,
            body: ClientIntegrationBody(clientIntegrationId: clientIntegrationId)
        )
    }

    // MARK: - POST /api/sms

    func getSmsRequest(for number: String, code: String) -> URLRequest? {
        makeRequest(
            path: "/api/sms",
            method: .post,
            body: SmsBody(number: number, code: code)
        )
    }

    // MARK: - Private helpers

    private func makeRequest<T: Encodable>(path: String, method: Method, body: T) -> URLRequest? {
        guard let url = URL(string: baseURL + path) else {
            assertionFailure("Invalid URL: \(baseURL + path)")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = baseHeader
        request.httpBody = try? encoder.encode(body)
        return request
    }

    private func makeRequest(path: String, method: Method) -> URLRequest? {
        guard let url = URL(string: baseURL + path) else {
            assertionFailure("Invalid URL: \(baseURL + path)")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        return request
    }
}

// MARK: - Request body models (Vapor camelCase format)

private struct UploadImagesBody: Encodable {
    let images: [String]
}

private struct PhoneBody: Encodable {
    let phoneNumber: String
}

private struct SmsBody: Encodable {
    let number: String
    let code: String
}

private struct ClientIntegrationBody: Encodable {
    let clientIntegrationId: String
}

/// Vapor-сервер ожидает camelCase ключи, в отличие от SearchAutoInput,
/// который использует uppercase CodingKeys для внешнего API.
private struct VaporSearchAutoBody: Encodable {
    let dateFrom: String
    let dateTo: String
    let brands: [String]
    let defaultPriceFrom: Int
    let defaultPriceTo: Int
    let autoClasses: [String]
    let powerMin: Int
    let powerMax: Int
}

private extension UIImage {
    func resized(maxDimension: CGFloat) -> UIImage {
        let pixelSize = CGSize(width: size.width * scale, height: size.height * scale)
        guard pixelSize.width > maxDimension || pixelSize.height > maxDimension else { return self }
        let ratio = maxDimension / max(pixelSize.width, pixelSize.height)
        let newSize = CGSize(width: (pixelSize.width * ratio).rounded(), height: (pixelSize.height * ratio).rounded())
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in self.draw(in: CGRect(origin: .zero, size: newSize)) }
    }
}
