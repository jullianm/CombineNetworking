//
//  Handler.swift
//  Experimentation+Combine
//
//  Created by Jullianm on 05/03/2020.
//  Copyright © 2020 Jullianm. All rights reserved.
//

import Combine
import Foundation

class ServiceHandler {
    static let shared = ServiceHandler()
    
    var handler: ((Result<ServiceConfig.StatusCode, ServiceError>) -> Void)?
    var subscriptions = Set<AnyCancellable>()
    
    private init() { }
        
    func receive(response: AnyPublisher<URLResponse, ServiceError>?) {
        response?
            .map(toHTTPURLResponse)
            .map(\.statusCode)
            .map(ServiceConfig.StatusCode.init)
            .sink(receiveCompletion: { completion in
                guard case .failure(let error) = completion else {
                    return
                }
                self.handler?(.failure(error))
            }, receiveValue: { code in
                self.handler?(.success(code))
            }).store(in: &subscriptions)
    }
}

extension ServiceHandler {
    func install(resultHandler: @escaping (Result<ServiceConfig.StatusCode, ServiceError>) -> Void) {
        handler = resultHandler
    }
    private func toHTTPURLResponse(response: URLResponse) -> HTTPURLResponse {
        return response as? HTTPURLResponse ?? .init()
    }
}
