# CombineNetworking

An experimental network layer built upon Combine and @propertyWrapper.

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
