//
//  Publisher+Extension.swift
//  Experimentation+Combine
//
//  Created by Jullianm on 05/03/2020.
//  Copyright © 2020 Jullianm. All rights reserved.
//
import Foundation
import Combine

extension Publisher {
    func result() -> Publishers.Map<Self, Result<Self.Output, ServiceError>> {
        map { output -> Result<Output, ServiceError> in
            return .success(output)
        }
    }
}
