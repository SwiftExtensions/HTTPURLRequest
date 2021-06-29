import XCTest
@testable import Networker


// MARK: - DataTask

extension HTTPURLRequestTests {
    override func setUp() {
        super.setUp()
        self.session = MockURLSession()
        self.request = URLRequest(url: self.url)
        self.sut = HTTPURLRequest(request: self.request, session: self.session)
    }
    
    override func tearDown() {
        self.request = nil
        self.session = nil
        self.sut = nil
        super.tearDown()
    }
    
    func test_dataTask_callsExpectedRequest() {
        self.sut.dataTask() { _ in }
        
        XCTAssertNotNil(self.request)
        XCTAssertEqual(self.session.lastRequest, self.request)
    }
    
    func test_dataTask_callsResumeOnTask() throws {
        self.sut.dataTask() { _ in }

        XCTAssertNotNil(self.session.lastTask)
        let lastTask = try XCTUnwrap(self.session.lastTask)
        XCTAssertTrue(lastTask.calledResume)
    }

    func test_dataTask_givenError_callsFailure() {
        let expectedError = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut)

        let result = self.runDataTask(data: Data(), self.response(200), expectedError)

        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.data)

        let actualError = result.error as NSError?
        XCTAssertEqual(actualError, expectedError)
    }

    typealias DataResult = (calledCompletion: Bool, data: DataResponse?, error: Error?)

    func runDataTask(data: Data?, _ response: HTTPURLResponse? = nil, _ error: Error? = nil) -> DataResult {
        var calledCompletion = false
        var receivedData: DataResponse?
        var receivedError: Error?

        self.sut.dataTask() { result in
            calledCompletion = true

            receivedData = result.success
            receivedError = result.failure
        }

        self.session.lastTask?.completionHandler(data, response, error)

        return (calledCompletion, receivedData, receivedError)
    }

    func response(_ statusCode: Int) -> HTTPURLResponse? {
        HTTPURLResponse(url: self.url, statusCode: statusCode)
    }

    func test_dataTask_emptyData_callsFailure() {
        let result = self.runDataTask(data: nil, self.response(200))
        let expectedError = HTTPURLRequest.Error.emptyData

        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.data)
        let actualError = result.error as? HTTPURLRequest.Error
        XCTAssertEqual(actualError, expectedError)
    }

    func test_dataTask_unknownResponse_callsFailure() {
        let result = self.runDataTask(data: Data())
        let expectedError = HTTPURLRequest.Error.unknownResponse

        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.data)
        let actualError = result.error as? HTTPURLRequest.Error
        XCTAssertEqual(actualError, expectedError)
    }

    func test_dataTask_statusCode500_callsFailure() throws {
        let response = self.response(500)
        let unwrappedResponse = try XCTUnwrap(response)
        let httpData = DataResponse(data: Data(), response: unwrappedResponse)
        let expectedError = HTTPURLRequest.Error.unsuccessfulHTTPStatusCode(httpData)

        let result = self.runDataTask(data: Data(), response)

        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.data)
        let actualError = result.error?.httpURLRequest
        XCTAssertEqual(actualError, expectedError)
    }

    func test_dataTask_givenDataAndSuccessResponseStatusCode_callsSuccess() throws {
        let result = self.runDataTask(data: Data(), self.response(200))

        XCTAssertTrue(result.calledCompletion)
        XCTAssertNotNil(result.data)
        XCTAssertNil(result.error)
    }
    
    @available(iOS 10.0, *)
    func test_dataTask_callsInCorrectDispatchQueue() {
        let targetQueue = DispatchQueue(label: #function)

        let expectation = self.expectation(description: #function)
        self.sut.dataTask(dispatchQueue: targetQueue) { result in
            dispatchPrecondition(condition: .onQueue(targetQueue))
            expectation.fulfill()
        }

        self.session.lastTask?.completionHandler(Data(), self.response(200), nil)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    
}

