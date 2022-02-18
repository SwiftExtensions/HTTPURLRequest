# Unit-Testing

A simple example of unit tests.

## Content
- [SafeDictionary](#SafeDictionary)
- [MockURLSession](#MockURLSession)
    - [Result](#Result)
- [Loader](#Loader)

## SafeDictionary

`SafeDictionary` is a thread safe helper dictionary class.
```swift
import Foundation

class SafeDictionary<Key: Hashable, Value> {
    private var dictionary = [Key : Value]()
    private let queue = DispatchQueue(
        label: "\(SafeDictionary.self)",
        attributes: .concurrent)
    
    subscript(key: Key) -> Value? {
        get {
            self.queue.sync {
                return self.dictionary[key]
            }
        }
        set {
            self.queue.async(flags: .barrier) {
                self.dictionary[key] = newValue
            }
        }
    }
}
```

[Go to content](#Content)

## MockURLSession

`MockURLSession` is a class for intercepting network requests.

```swift
import Foundation

class MockURLSession: URLProtocol {
    static var results = SafeDictionary<String, Result>()
    
    override class func canInit(with request: URLRequest) -> Bool {
        MockURLSession.results[request.url?.absoluteString ?? ""] != nil
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        let result = MockURLSession.results[request.url?.absoluteString ?? ""]
        if let response = result?.response {
            self.client?.urlProtocol(self,
                                     didReceive: response,
                                     cacheStoragePolicy: .notAllowed)
        }
        if let data = result?.data {
            self.client?.urlProtocol(self, didLoad: data)
        }
        if let error = result?.error {
            self.client?.urlProtocol(self, didFailWithError: error)
        }
        self.client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        
    }
}
```

[Go to content](#Content)

### Result

`Result` is another helper class of [`MockURLSession`](#MockURLSession).

```swift
import Foundation

extension MockURLSession {
    struct Result {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }
}
```

[Go to content](#Content)

## Loader

`Loader` is an example for Unit Testing.

```swift
import Networker

struct Loader {
    typealias Completion = (Result<DataResponse, Error>) -> Void

    let session: URLSession

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    @discardableResult
    public func load(
        url: URL,
        dispatchQueue: DispatchQueue? = nil,
        completionHandler: @escaping Completion) -> URLSessionDataTask
    {
        let request = HTTPURLRequest(url: url, session: self.session)
        return request.dataTask() { response in
            if let dispatchQueue = dispatchQueue {
                dispatchQueue.async { completion(response) }
            } else {
                completion(response)
            }
        }
    }
}
```

[Go to content](#Content)

## LoaderTests

`LoaderTests` is an example of Unit Tests.

```swift
import XCTest
import Networker

final class LoaderTests: XCTestCase {
    var sut: Loader!
    var mockSession: URLSession!
    
    override func setUpWithError() throws {
        self.mockSession = URLSession.mockSession(protocolClass: MockURLSession.self)
    }
    
    override func tearDownWithError() throws {
        self.sut = nil
        self.mockSession = nil
    }
}

extension URLSession {
    static func mockSession(protocolClass: AnyClass) -> URLSession {
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [protocolClass]
        URLProtocol.registerClass(protocolClass)
        
        return URLSession(configuration: sessionConfiguration)
    }
}
```

```swift
// MARK: - URL tests

extension LoaderTests {
    func test_loadURLError_callsFailture() throws {
        let expectedError = NSError.urlRequestTimedOut
        let result = MockURLSession.Result(data: nil, response: nil, error: expectedError)
        let path = "https://example.com/" + #function.description
        MockURLSession.results[path] = result
        let url = URL(string: path)!
        
        self.sut = Loader(session: self.mockSession)
        let dataTask = self.sut.load(url: url) { response in
            XCTAssertNil(response.success)
            XCTAssertNotNil(response.failure)

            let actualError = response.failure as NSError?
            XCTAssertNotNil(actualError)
            XCTAssertEqual(actualError?.domain, expectedError.domain)
            XCTAssertEqual(actualError?.code, expectedError.code)
            
            MockURLSession.results[path] = nil
        }
        XCTAssertNotNil(dataTask)
        XCTAssertEqual(dataTask.originalRequest?.url, url)
    }

    func test_loadURL_callsSuccess() throws {
        let data = Data("Test".utf8)
        let response = HTTPURLResponse.ok200
        let result = MockURLSession.Result(data: data, response: response, error: nil)
        let path = "https://example.com/" + #function.description
        MockURLSession.results[path] = result
        let url = URL(string: path)!

        self.sut = Loader(session: self.mockSession)
        let dataTask = self.sut.load(url: url) { response in
            XCTAssertNotNil(response.success)
            XCTAssertNil(response.failure)
            XCTAssertEqual(response.success?.data, data)
            
            MockURLSession.results[path] = nil
        }
        XCTAssertNotNil(dataTask)
        XCTAssertEqual(dataTask.originalRequest?.url, url)
    }

    @available(iOS 10.0, *)
    func test_loadURL_callsInCorrectDispatchQueue() {
        let data = Data("Test".utf8)
        let response = HTTPURLResponse.ok200
        let result = MockURLSession.Result(data: data, response: response, error: nil)
        let path = "https://example.com/" + #function.description
        MockURLSession.results[path] = result
        let url = URL(string: path)!

        let targetQueue = DispatchQueue(label: #function)

        self.sut = Loader(session: self.mockSession)
        let dataTask = self.sut.load(url: url, dispatchQueue: targetQueue) { response in
            dispatchPrecondition(condition: .onQueue(targetQueue))
            DispatchQueue.main.async {
                XCTAssertNotNil(response.success)
                XCTAssertNotNil(response.failure)
                
                MockURLSession.results[path] = nil
            }
        }
        XCTAssertNotNil(dataTask)
        XCTAssertEqual(dataTask.originalRequest?.url, url)
    }
}

extension NSError {
    static var urlRequestTimedOut: NSError {
        NSError(
            domain: NSURLErrorDomain,
            code: NSURLErrorTimedOut,
            userInfo: nil)
    }   
}

extension HTTPURLResponse {
    static var ok200: HTTPURLResponse {
        let url = URL(string: "https://example.com/")!
        
        return HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil)!
    }
}

```

[Go to content](#Content)
