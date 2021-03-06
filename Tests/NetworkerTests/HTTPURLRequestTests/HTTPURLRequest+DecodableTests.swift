import XCTest
@testable import Networker

// MARK: - Decodable DataTask

extension HTTPURLRequestTests {
    typealias DecodableResult<T: Decodable> = (calledCompletion: Bool, decoded: DecodableResponse<T>?, error: Error?)

    func runDecodableDataTask<T: Decodable>(type: T.Type, data: Data?, _ response: HTTPURLResponse? = nil, _ error: Error? = nil) -> DecodableResult<T> {
        var calledCompletion = false
        var receivedDecoded: DecodableResponse<T>?
        var receivedError: Error?

        self.sut.dataTask(decoding: T.self) { result in
            calledCompletion = true

            receivedDecoded = result.success
            receivedError = result.failure
        }

        self.session.lastTask?.completionHandler(data, response, error)

        return (calledCompletion, receivedDecoded, receivedError)
    }
    
    func test_decodingDataTask_givenInvalidData_callsFailure() {
        let result = self.runDecodableDataTask(type: TestJSON.self, data: Data(), self.response(200))

        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.decoded)
        XCTAssertNotNil(result.error)
    }
    
    func test_decodingDataTask_validData_callsSuccess() throws {
        let jsonData = Data(jsonString.utf8)
        let result = self.runDecodableDataTask(type: TestJSON.self, data: jsonData, self.response(200))

        XCTAssertTrue(result.calledCompletion)
        XCTAssertNotNil(result.decoded)
        XCTAssertNil(result.error)
    }
    
    @available(iOS 10.0, *)
    func test_decodingDataTask_callsInCorrectDispatchQueue() {
        let jsonData = Data(jsonString.utf8)
        let targetQueue = DispatchQueue(label: #function)

        let expectation = self.expectation(description: #function)
        self.sut.dataTask(decoding: TestJSON.self, dispatchQueue: targetQueue) { result in
            dispatchPrecondition(condition: .onQueue(targetQueue))
            expectation.fulfill()
        }

        self.session.lastTask?.completionHandler(jsonData, self.response(200), nil)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    
}
