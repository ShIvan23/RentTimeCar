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
