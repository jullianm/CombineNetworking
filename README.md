# CombineNetworking

An experimental testable network layer built upon Combine and @propertyWrapper.

__Service Manager__

```swift
struct ServiceManager {
    private static var service: Service = URLSession.shared
    
    @ServiceWrapper(service: service, endpoint: .posts(model: [Post].self))
    static var posts: AnyPublisher<[Post], ServiceError>
    
    @ServiceWrapper(service: service, endpoint: .comments(model: [Comment].self))
    static var comments: AnyPublisher<[Comment], ServiceError>
}
```

__Service Wrapper__

```swift
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
```

__Service Manager__

```swift
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
```

