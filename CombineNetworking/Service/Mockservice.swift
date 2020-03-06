//
//  Mockservice.swift
//  Experimentation+Combine
//
//  Created by Jullianm on 05/03/2020.
//  Copyright © 2020 Jullianm. All rights reserved.
//

import Combine
import Foundation

struct MockService: Service {
    var error: ServiceError? 
    var response: ServiceConfig.StatusCode
    
    func fetch<T: Decodable>(endpoint: ServiceConfig.Endpoint<T>,
                             queue: DispatchQueue = .main) -> AnyPublisher<T, ServiceError> {
        guard let sampleModel = try? JSONDecoder().decode(endpoint.decodable, from: endpoint.sampleData) else {
            fatalError("Sample model doesn't exist in specified bundle")
        }
        
        return Just(sampleModel)
            .tryMap { model in
                if let error = error {
                    throw error
                }
                return model
        }
        .mapError { $0 as! ServiceError }
        .receive(on: queue)
        .eraseToAnyPublisher()
    }
    
    func send<T: Encodable>(endpoint: ServiceConfig.Endpoint<T>,
                            queue: DispatchQueue = .main,
                            model: T) -> AnyPublisher<URLResponse, ServiceError> {
        return Just(endpoint.sampleResponse(response))
            .tryMap { response in
                if let error = error {
                    throw error
                }
                return response
        }
        .mapError { $0 as! ServiceError }
        .receive(on: queue)
        .eraseToAnyPublisher()
    }
}
