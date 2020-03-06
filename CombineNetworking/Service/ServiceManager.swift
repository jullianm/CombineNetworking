//
//  Manager.swift
//  Experimentation+Combine
//
//  Created by Jullianm on 05/03/2020.
//  Copyright © 2020 Jullianm. All rights reserved.
//

import Combine
import Foundation

/// Encapsulates various kinds of network requests.
struct ServiceManager {
    private static var service: Service = URLSession.shared
    
    @ServiceWrapper(service: service, endpoint: .posts(model: [Post].self))
    static var posts: AnyPublisher<[Post], ServiceError>
    
    @ServiceWrapper(service: service, endpoint: .comments(model: [Comment].self))
    static var comments: AnyPublisher<[Comment], ServiceError>
}

extension ServiceManager {
    enum ServiceType {
        case webservice
        case mockservice(failWithError: ServiceError? = nil, statusCode: ServiceConfig.StatusCode = .success())
    }
    
    /// A service must be injected in view models that require network requests.
    /// - Parameter service: The type of service to use : `mockservice` or `webservice`.
    static func install(service: ServiceType) {
        switch service {
        case .webservice:
            ServiceManager.service = URLSession.shared
        case let .mockservice(error, statusCode):
            ServiceManager.service = MockService(error: error, response: statusCode)
        }
    }
}
