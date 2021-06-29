import XCTest
@testable import Networker

final class HTTPURLRequestTests: XCTestCase {
    var sut: HTTPURLRequest!
    var session: MockURLSession!
    let path = "http://example.com/"
    let url = URL(string: "http://example.com/")!
    var request: URLRequest!
}

// MARK: - Initialization

extension HTTPURLRequestTests {
    func test_defaultInit_setsRequestAndSession() {
        let urlRequest = self.url.urlRequest
        let session = URLSession()
        self.sut = HTTPURLRequest(request: urlRequest, session: session)
        
        XCTAssertNotNil(self.sut.request)
        XCTAssertEqual(self.sut.request, urlRequest)
        XCTAssertNotNil(self.sut.session)
        XCTAssertEqual(self.sut.session, session)
    }
    
    func test_defaultInitWithoutSession_setsRequestAndSession() {
        let urlRequest = self.url.urlRequest
        self.sut = HTTPURLRequest(request: urlRequest)
        
        XCTAssertNotNil(self.sut.request)
        XCTAssertEqual(self.sut.request, urlRequest)
        XCTAssertNotNil(self.sut.session)
        XCTAssertEqual(self.sut.session, URLSession.shared)
    }
    
    func test_initWithEmptyPath_throws() {
        let request = { try HTTPURLRequest(path: "") }
        let expectedError = HTTPURLRequest.Error.emptyPath
        var actualError: Error? = nil
        
        XCTAssertThrowsError(try request())
        
        do {
            _ = try request()
        } catch {
            actualError = error
        }
        
        XCTAssertNotNil(actualError)
        XCTAssertEqual(actualError as? HTTPURLRequest.Error, expectedError)
    }
    
    func test_initWithInvalidPath_throws() {
        let path = "INVALID PATH"
        let request = { try HTTPURLRequest(path: path) }
        let expectedError = HTTPURLRequest.Error.invalidPath(path)
        var actualError: Error? = nil
        
        XCTAssertThrowsError(try request())
        
        do {
            _ = try request()
        } catch {
            actualError = error
        }
        
        XCTAssertNotNil(actualError)
        XCTAssertEqual(actualError as? HTTPURLRequest.Error, expectedError)
    }
    
    func test_pathInit_setsRequestAndSession() {
        let session = URLSession()
        self.sut = try! HTTPURLRequest(path: self.path, session: session)
        
        XCTAssertNotNil(self.sut.request)
        XCTAssertEqual(self.sut.request, self.path.url!.urlRequest)
        XCTAssertNotNil(self.sut.session)
        XCTAssertEqual(self.sut.session, session)
    }
    
    func test_pathInitWithoutSession_setsRequestAndSession() {
        self.sut = try! HTTPURLRequest(path: self.path)
        
        XCTAssertNotNil(self.sut.request)
        XCTAssertEqual(self.sut.request, self.path.url!.urlRequest)
        XCTAssertNotNil(self.sut.session)
        XCTAssertEqual(self.sut.session, URLSession.shared)
    }
    
    func test_createWithInvalidPath_createsFailureResult() {
        let path = "INVALID PATH"
        let result = HTTPURLRequest.create(path: path)
        
        XCTAssertNil(result.success)
        XCTAssertNotNil(result.failure)
    }
    
    func test_createWithValidPath_createsSuccessResult() {
        let result = HTTPURLRequest.create(path: self.path)
        
        XCTAssertNotNil(result.success)
        XCTAssertNil(result.failure)
    }

    static var allTests = [
        ("test_defaultInit_setsRequestAndSession", test_defaultInit_setsRequestAndSession),
    ]
}

// MARK: - Image DataTask

extension HTTPURLRequestTests {
    typealias ImageResult = (calledCompletion: Bool, image: ImageResponse?, error: Error?)

    func runImageDataTask(data: Data?, _ response: HTTPURLResponse? = nil, _ error: Error? = nil) -> ImageResult {
        var calledCompletion = false
        var receivedImage: ImageResponse?
        var receivedError: Error?

        self.sut.imageDataTask() { result in
            calledCompletion = true

            receivedImage = result.success
            receivedError = result.failure
        }

        self.session.lastTask?.completionHandler(data, response, error)

        return (calledCompletion, receivedImage, receivedError)
    }
    
    func test_imageDataTask_givenInvalidData_callsCompletionWithFailure() {
        let result = self.runImageDataTask(data: Data(), self.response(200))

        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.image)
        XCTAssertNotNil(result.error)
    }
    
    func test_imageDataTask_validData_callsCompletionWithSuccess() throws {
        let image = UIImage.create(with: .black, size: CGSize(width: 10, height: 10))
        let imageData = image!.pngData()
        let result = self.runImageDataTask(data: imageData, self.response(200))

        XCTAssertTrue(result.calledCompletion)
        XCTAssertNotNil(result.image)
        XCTAssertNil(result.error)
    }
}


// MARK: - Mock Classes

typealias MockCompletion = (Data?, URLResponse?, Error?) -> Void

class MockURLSession: URLSession {
    private (set) var lastRequest: URLRequest?
    private (set) var lastTask: MockURLSessionDataTask?
    
    override init() { }
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping MockCompletion) -> URLSessionDataTask {
        self.lastRequest = request
        let lastTask = MockURLSessionDataTask(completionHandler: completionHandler, request: request)
        self.lastTask = lastTask
        
        return lastTask
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    var completionHandler: MockCompletion
    var request: URLRequest
    var calledResume = false
    
    init(completionHandler: @escaping MockCompletion, request: URLRequest) {
        self.completionHandler = completionHandler
        self.request = request
    }

    override func resume() {
        self.calledResume = true
    }
}
