//
//  Error.swift
//  Experimentation+Combine
//
//  Created by Jullianm on 05/03/2020.
//  Copyright © 2020 Jullianm. All rights reserved.
//

import Foundation

enum ServiceError: Swift.Error {
    case network(Swift.Error? = nil)
    case decoding(Swift.Error? = nil)
    case other(statusCode: ServiceConfig.StatusCode)
}
