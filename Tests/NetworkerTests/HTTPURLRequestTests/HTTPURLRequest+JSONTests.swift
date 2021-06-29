import XCTest
@testable import Networker

// MARK: - JSON DataTask

extension HTTPURLRequestTests {
    typealias JSONResult = (calledCompletion: Bool, json: JSONResponse?, error: Error?)

    func runJSONDataTask(data: Data?, _ response: HTTPURLResponse? = nil, _ error: Error? = nil) -> JSONResult {
        var calledCompletion = false
        var receivedJSON: JSONResponse?
        var receivedError: Error?

        self.sut.jsonDataTask() { result in
            calledCompletion = true

            receivedJSON = result.success
            receivedError = result.failure
        }

        self.session.lastTask?.completionHandler(data, response, error)

        return (calledCompletion, receivedJSON, receivedError)
    }
    
    func test_jsonDataTask_givenInvalidData_callsCompletionWithFailure() {
        let result = self.runJSONDataTask(data: Data(), self.response(200))

        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.json)
        XCTAssertNotNil(result.error)
    }
    
    func test_jsonDataTask_validData_callsCompletionWithSuccess() throws {
        let jsonData = Data(jsonString.utf8)
        let result = self.runJSONDataTask(data: jsonData, self.response(200))

        XCTAssertTrue(result.calledCompletion)
        XCTAssertNotNil(result.json)
        XCTAssertNil(result.error)
    }
    
    
}
