//
//  Wrapper.swift
//  Experimentation+Combine
//
//  Created by Jullianm on 05/03/2020.
//  Copyright © 2020 Jullianm. All rights reserved.
//

import Combine
import Foundation

@propertyWrapper
final class ServiceWrapper<T: Codable> {
    private var service: Service
    private var endpoint: ServiceConfig.Endpoint<T>
    private var handler: ServiceHandler
    
    init(service: Service, endpoint: ServiceConfig.Endpoint<T>, handler: ServiceHandler = .shared) {
        self.service = service
        self.endpoint = endpoint
        self.handler = handler
    }
    
    var wrappedValue: AnyPublisher<T, ServiceError> {
        get {
            return service.fetch(endpoint: endpoint, queue: .main)
        }
        set {
            let response = newValue.flatMap { [unowned self] model in
                self.service.send(endpoint: self.endpoint, queue: .main, model: model)
            }.eraseToAnyPublisher()
            
            handler.receive(response: response)
        }
    }
}
