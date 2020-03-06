//
//  ViewModel.swift
//  Experimentation+Combine
//
//  Created by Jullianm on 05/03/2020.
//  Copyright © 2020 Jullianm. All rights reserved.
//

import Combine
import Foundation

class ViewModel: ViewModelable {
    var subscriptions = Set<AnyCancellable>()
    
    struct Input {
        var didSelectModel: PassthroughSubject<Post, Never>
    }
    
    struct Output {
        var didReceiveResponse: AnyPublisher<ServiceConfig.StatusCode, ServiceError>
        var didReceiveData: AnyPublisher<[Post], ServiceError>
    }
    
    let output: Output
    let input: Input
    
    var didReceiveResponse: PassthroughSubject<ServiceConfig.StatusCode, ServiceError>
    var didReceiveData: PassthroughSubject<[Post], ServiceError>
    var didSelectModel: PassthroughSubject<Post, Never>
    
    init(service: ServiceManager.ServiceType) {
        self.didReceiveData = .init()
        self.didReceiveResponse = .init()
        self.didSelectModel = .init()
        self.input = .init(didSelectModel: didSelectModel)
        self.output = .init(didReceiveResponse: didReceiveResponse.eraseToAnyPublisher(),
                            didReceiveData: didReceiveData.eraseToAnyPublisher())
        
        install(service: service)
        bind()
    }
    
    func install(service: ServiceManager.ServiceType) {
        ServiceManager.install(service: service)
        ServiceHandler.shared.install(resultHandler: handle(result:))
    }
    
    private func bind() {
        ServiceManager.posts.result()
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] in self?.handle(result: $0) })
            .store(in: &subscriptions)
        
        didSelectModel
            .sink(receiveCompletion: { _ in }, receiveValue: { post in
                print(post)
            }).store(in: &subscriptions)
    }
}
