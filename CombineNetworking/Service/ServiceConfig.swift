//
//  Config.swift
//  Experimentation+Combine
//
//  Created by Jullianm on 05/03/2020.
//  Copyright © 2020 Jullianm. All rights reserved.
//

import Foundation

/// Namespace for service configuration.
enum ServiceConfig {}

extension ServiceConfig {
    enum Endpoint<T: Decodable> {
        case posts(model: T.Type)
        case comments(model: T.Type)

        var decodable: T.Type {
            switch self {
            case .posts(let posts):
                return posts
            case .comments(let comments):
                return comments
            }
        }
        
        var sampleResponse: (StatusCode) -> URLResponse {
            return { code in
                switch code {
                case let .success(code), let .redirection(code), let .clientError(code), let .serverError(code):
                    return HTTPURLResponse(url: self.url, statusCode: code, httpVersion: "", headerFields: nil)!
                }
            }
        }
        
        var sampleData: Data {
            switch self {
            case .posts:
                let path = Bundle.main.path(forResource: "posts.json", ofType: nil)!
                return try! Data(contentsOf: URL(fileURLWithPath: path))
            case .comments:
                let path = Bundle.main.path(forResource: "comments.json", ofType: nil)!
                return try! Data(contentsOf: URL(fileURLWithPath: path))
            }
        }
        
        var url: URL {
            return urlComponents.url!
        }
        
        func urlRequest<T: Encodable>(model: T) -> URLRequest {
            var urlRequest = URLRequest(url: url)
            
            switch self {
            case .posts:
                urlRequest.httpMethod = "PUT"
            case .comments:
                urlRequest.httpMethod = "POST"
            }
            
            urlRequest.httpBody = try? JSONEncoder().encode(model)
            
            return urlRequest
        }
        
        private var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = "https"
            components.host = "jsonplaceholder.typicode.com"
            components.path = path
            
            return components
        }
                
        private var path: String {
            switch self {
            case .comments:
                return "/comments"
            case .posts:
                return "/posts"
            }
        }
    }
    
    enum StatusCode {
        case success(Int = 200)
        case redirection(Int = 300)
        case clientError(Int = 400)
        case serverError(Int = 500)
        
        init(code: Int) {
            switch code {
            case 200..<300:
                self = .success(code)
            case 300..<400:
                self = .redirection(code)
            case 400..<500:
                self = .clientError(code)
            default:
                self = .serverError(code)
            }
        }
    }
}
