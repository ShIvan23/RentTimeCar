//
//  NetworkManager.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 30.07.2025.
//

import Foundation

typealias JSONCompletionHandler = (Data?, HTTPURLResponse?, Error?) -> Void

final class NetworkManager {
    private let sessionConfiguration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.httpShouldUsePipelining = false
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        return config
    }()

    /// Конфигурация без системного прокси — для работы с VPN в дебаге без Proxyman
    private let sessionConfigurationNoProxy: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.httpShouldUsePipelining = false
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.connectionProxyDictionary = [:]  // отключает Proxyman/Charles
        return config
    }()

    private lazy var session: URLSession = {
        #if DEBUG
        // Переключи на sessionConfigurationNoProxy если используешь VPN без Proxyman
        return URLSession(configuration: sessionConfiguration, delegate: TLSBypassDelegate(), delegateQueue: nil)
        #else
        return URLSession(configuration: sessionConfiguration)
        #endif
    }()

    private static let retryableErrorCodes: Set<Int> = [
        NSURLErrorNetworkConnectionLost,   // -1005
        NSURLErrorNotConnectedToInternet,  // -1009
        NSURLErrorTimedOut,                // -1001
    ]

    func fetch<T: Decodable>(request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        fetch(request: request, retries: 2, completion: completion)
    }

    private func fetch<T: Decodable>(request: URLRequest, retries: Int, completion: @escaping (Result<T, Error>) -> Void) {
        let dataTask = JSONTask(request: request) { [weak self] data, response, error in
            if let error = error as NSError?,
               Self.retryableErrorCodes.contains(error.code),
               retries > 0 {
                DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                    self?.fetch(request: request, retries: retries - 1, completion: completion)
                }
                return
            }

            guard let data = data else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(NSError()))
                }
                return
            }

            if let value = self?.decodeJSON(type: T.self, from: data) {
                completion(.success(value))
            } else {
                let error = NSError()
                completion(.failure(error))
            }
        }
        dataTask.resume()
    }
    
    // MARK: - Upload with progress

    func upload<T: Decodable>(
        request: URLRequest,
        body: Data,
        onProgress: @escaping (Double) -> Void,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let delegate = UploadDelegate(
            onProgress: onProgress,
            onComplete: { [weak self] data, error in
                if let error {
                    completion(.failure(error))
                    return
                }
                if let value = self?.decodeJSON(type: T.self, from: data) {
                    completion(.success(value))
                } else {
                    completion(.failure(NSError()))
                }
            }
        )
        let uploadSession = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
        uploadSession.uploadTask(with: request, from: body).resume()
    }

    // MARK: - Private

    private func JSONTask(request: URLRequest, completion: @escaping JSONCompletionHandler) -> URLSessionTask {
        
        let dataTask = session.dataTask(with: request) { data, response, error in
            
            guard let HTTPResponse = response as? HTTPURLResponse else {
                let error = error
                completion(nil, nil, error)
                return
            }
            
            switch HTTPResponse.statusCode {
            case 200:
                completion(data, HTTPResponse, nil)
            case 422:
                completion(data, HTTPResponse, error)
            default:
                completion(data, HTTPResponse, error)
            }
        }
        return dataTask
    }
    
    private func decodeJSON<T: Decodable>(type: T.Type, from: Data?) -> T? {
        
        let decoder = JSONDecoder()
        
        guard let data = from else { return nil }
        
        do {
            let object = try decoder.decode(T.self, from: data)
            return object
        }
        
        catch DecodingError.dataCorrupted(let context) {
            debugPrint(DecodingError.dataCorrupted(context))
        } catch DecodingError.keyNotFound(let key, let context) {
            debugPrint(DecodingError.keyNotFound(key,context))
        } catch DecodingError.typeMismatch(let type, let context) {
            debugPrint(DecodingError.typeMismatch(type,context))
        } catch DecodingError.valueNotFound(let value, let context) {
            debugPrint(DecodingError.valueNotFound(value,context))
        } catch let error{
            debugPrint(error)
        }
        return nil
    }
}

// MARK: - TLSBypassDelegate (DEBUG only)

#if DEBUG
/// Принимает любой TLS-сертификат. Нужен для работы с Proxyman/Charles.
/// НЕ использовать в продакшене.
private final class TLSBypassDelegate: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        print("🔐 TLSBypassDelegate called, method: \(challenge.protectionSpace.authenticationMethod)")
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
#endif

// MARK: - UploadDelegate

/// Делегат одноразовой upload-сессии.
/// URLSession сильно удерживает делегат до вызова finishTasksAndInvalidate(),
/// поэтому дополнительного хранения снаружи не требуется.
private final class UploadDelegate: NSObject {

    private let onProgress: (Double) -> Void
    private let onComplete: (Data?, Error?) -> Void
    private var receivedData = Data()
    private var hasCompleted = false

    init(
        onProgress: @escaping (Double) -> Void,
        onComplete: @escaping (Data?, Error?) -> Void
    ) {
        self.onProgress = onProgress
        self.onComplete = onComplete
    }
}

extension UploadDelegate: URLSessionTaskDelegate {

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        guard totalBytesExpectedToSend > 0 else { return }
        let value = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        DispatchQueue.main.async { [weak self] in self?.onProgress(value) }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard !hasCompleted else { return }
        hasCompleted = true
        onComplete(receivedData.isEmpty ? nil : receivedData, error)
        session.finishTasksAndInvalidate()
    }
}

#if DEBUG
extension UploadDelegate: URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard let trust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        completionHandler(.useCredential, URLCredential(trust: trust))
    }
}
#endif

extension UploadDelegate: URLSessionDataDelegate {

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? -1
            hasCompleted = true
            onComplete(nil, NSError(domain: "HTTPError", code: code))
            completionHandler(.cancel)
            return
        }
        completionHandler(.allow)
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {
        receivedData.append(data)
    }
}
