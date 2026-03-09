//
//  NetworkManager.swift
//  RentTimeCar
//
//  Created by ivanshishkin on 30.07.2025.
//

import Foundation

typealias JSONCompletionHandler = (Data?, HTTPURLResponse?, Error?) -> Void

final class NetworkManager {
    private let sessionConfiguration = URLSessionConfiguration.default
    private lazy var session = URLSession(configuration: sessionConfiguration)
    
    func fetch<T: Decodable>(request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        
        let dataTask = JSONTask(request: request) { [weak self] data, response, error in
            guard let data = data else {
                if let error = error {
                    completion(.failure(error))
                }
                let unownedError = NSError()
                completion(.failure(unownedError))
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
