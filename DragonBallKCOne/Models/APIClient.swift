//
//  APIClient.swift
//  DragonBallKCOne
//
//  Created by Natacha Saldaña on 02-03-25.
//

import Foundation

enum NetworkError: Error, Equatable {
    case malformURL
    case noData
    case statusCode(code: Int?)
    case decodingError
    case unknown
}

protocol APIClientProtocol {
    func tokenAuthenticated(_ request: URLRequest, completion:  @escaping (Result<String, NetworkError>) -> Void)
    func request<T: Decodable>(_ request: URLRequest, using: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void)
}

struct APIClient: APIClientProtocol {
    let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func tokenAuthenticated(
        _ request: URLRequest,
        completion:  @escaping (Result<String, NetworkError>) -> Void
    ) {
        let task = session.dataTask(with: request) {
            data, response, error in
            var result: Result<String, NetworkError> = .failure(.unknown)
            
            defer {
                completion(result)
            }
            
            guard error == nil else {
                result = .failure(.unknown)
                return
            }
            
            guard let data  else {
                result = .failure(.noData)
                return
            }
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            
            guard statusCode == 200 else {
                result = .failure(.statusCode(code: statusCode))
                return
            }
            
            guard let token = String(data: data, encoding: .utf8) else {
                result = .failure(.decodingError)
                return
            }
            
            result = .success(token)
        }
        task.resume()
    }
    
    func request<T: Decodable>(
        _ request: URLRequest,
        using: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        let task = session.dataTask(with: request) { data, response, error in
            var result: Result<T, NetworkError> = .failure(.unknown)
            
            defer {
                completion(result)
            }
            
            guard error == nil else {
                result = .failure(.unknown)
                return
            }
            
            guard let data else {
                result = .failure(.noData)
                return
            }
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            
            guard statusCode == 200 else {
                result = .failure(.statusCode(code: statusCode))
                return
            }
            
            guard let model = try? JSONDecoder().decode(using, from: data) else {
                result = .failure(.decodingError)
                return
            }
        
            result = .success(model)
        }
        task.resume()
    }
}
