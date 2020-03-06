//
//  Services.swift
//  Experimentation+Combine
//
//  Created by Jullianm on 05/03/2020.
//  Copyright © 2020 Jullianm. All rights reserved.
//

import Combine
import Foundation

protocol Service {
    func fetch<T: Decodable>(endpoint: ServiceConfig.Endpoint<T>, queue: DispatchQueue) -> AnyPublisher<T, ServiceError>
    func send<T: Encodable>(endpoint: ServiceConfig.Endpoint<T>, queue: DispatchQueue, model: T) -> AnyPublisher<URLResponse, ServiceError>
}

extension URLSession: Service {
    func fetch<T: Decodable>(endpoint: ServiceConfig.Endpoint<T>,
                             queue: DispatchQueue = .main) -> AnyPublisher<T, ServiceError> {
        return self
            .dataTaskPublisher(for: endpoint.url)
            .mapError(ServiceError.network)
            .map(\.data)
            .decode(type: endpoint.decodable, decoder: JSONDecoder())
            .mapError(ServiceError.decoding)
            .receive(on: queue)
            .eraseToAnyPublisher()
    }
    
    func send<T: Encodable>(endpoint: ServiceConfig.Endpoint<T>,
                            queue: DispatchQueue = .main,
                            model: T) -> AnyPublisher<URLResponse, ServiceError> {
        return self
            .dataTaskPublisher(for: endpoint.urlRequest(model: model))
            .mapError(ServiceError.network)
            .map(\.response)
            .receive(on: queue)
            .eraseToAnyPublisher()
    }
}



