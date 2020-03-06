//
//  ViewModelable.swift
//  Experimentation+Combine
//
//  Created by Jullianm on 06/03/2020.
//  Copyright © 2020 Jullianm. All rights reserved.
//

import Combine
import UIKit

protocol ViewModelable: AnyObject {
    associatedtype T
    func install(service: ServiceManager.ServiceType)
    
    var didReceiveData: PassthroughSubject<T, ServiceError> { get set }
    var didReceiveResponse: PassthroughSubject<ServiceConfig.StatusCode, ServiceError> { get set }
}

extension ViewModelable {
    /// Handles response received from service for a `POST` request.
    /// - Parameter result: A result containing either a success with some status code or a failure with some specified `ServiceError`.
    func handle(result: Result<ServiceConfig.StatusCode, ServiceError>) {
        switch result {
        case let .success(statusCode):
            switch statusCode {
            case .success:
                didReceiveResponse.send(statusCode)
            default:
                didReceiveResponse.send(completion: .failure(.other(statusCode: statusCode)))
            }
        case .failure(let error):
            didReceiveResponse.send(completion: .failure(error))
        }
    }
    
    /// Handles data received from service for a `GET` request.
    /// - Parameter result: A result containing either a success with some decoded data or a failure with some specified `ServiceError`.
    func handle(result: Result<T, ServiceError>) {
        switch result {
        case let .success(model):
            didReceiveData.send(model)
        case .failure(let error):
            didReceiveData.send(completion: .failure(error))
        }
    }
}
