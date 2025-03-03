//
//  NetworkModel.swift
//  DragonBallKCOne
//
//  Created by Natacha Saldaña on 02-03-25.
//

import Foundation

final class NetworkModel {
    private var baseComponent: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "dragonball.keepcoding.education"
        return components
    }
    
    private var token: String?
    
    private let client: APIClientProtocol
    
    init(client: APIClientProtocol = APIClient()) {
        self.client = client
    }
    
    func login(user: String, password: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
        var components = baseComponent
        components.path = "/api/auth/login"
        
        guard let url = components.url else {
            completion(.failure(.malformURL))
            return
        }
        
        let loginString = String(format: "%@:%@", user, password)
        
        guard let loginData = loginString.data(using: .utf8) else {
            completion(.failure(.noData))
            return
        }
        
        let base64LoginString = loginData.base64EncodedString()
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Basic\(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        client.tokenAuthenticated(request) { [weak self] result in
            switch result {
            case let .success(token):
                self?.token = token
            case .failure(_):
                break
            }
            completion(result)
        }
    }
    
    func getHeros(completion: @escaping (Result<[HeroModel], NetworkError>) -> Void) {
        var components = baseComponent
        components.path = "/api/heros/all"
        
        guard let url = components.url else {
            completion(.failure(.malformURL))
            return
        }
        
        guard let serializedBody = try? JSONSerialization.data(withJSONObject: ["name":""]) else {
            completion(.failure(.unknown))
            return
        }
        
        guard let token else {
            completion(.failure(.missingToken))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("Application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = serializedBody
        
        client.request(request, using: [HeroModel].self, completion: completion)
    }
    
    func getTransformations(for hero: HeroModel, completion: @escaping (Result<[TransformationsModel], NetworkError>) -> Void) {
        
        var components = baseComponent
        components.path = "/api/heros/transformation"
        
        guard let url = components.url else {
            completion(.failure(.malformURL))
            return
        }
        
        guard let serializedBody = try? JSONSerialization.data(withJSONObject: ["id": hero.id]) else {
            completion(.failure(.unknown))
            return
        }
        
        guard let token else {
            completion(.failure(.missingToken))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod  = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("Application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = serializedBody
        
        client.request(request, using: [TransformationsModel].self, completion: completion)
    }
}
