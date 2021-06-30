import XCTest
@testable import Networker

final class DataTaskHandlerTests: XCTestCase {
    let successfulResponse = HTTPURLResponse(url: URL(string: "http://example.com")!, statusCode: 200)!
    let unsuccessfulResponse = HTTPURLResponse(url: URL(string: "http://example.com")!, statusCode: 500)!
    var sut: DataTaskHandler!
    
    func test_execute_error_callsFailure() {
        let expectedError = NSError(domain: #function, code: 100, userInfo: nil)
        var testResponse: Result<DataResponse, Swift.Error>? = nil
        
        self.sut = DataTaskHandler(
            data: nil,
            response: self.successfulResponse,
            error: expectedError)
        { response in testResponse = response }
        
        self.sut.execute()
        
        XCTAssertNotNil(testResponse)
        XCTAssertNotNil(testResponse?.failure)
        let actualErrorCode = (testResponse?.failure as NSError?)?.code
        XCTAssertEqual(actualErrorCode, expectedError.code)
    }
    
    func test_execute_emptyData_callsFailure() {
        let expectedError = HTTPURLRequest.Error.emptyData
        var testResponse: Result<DataResponse, Swift.Error>? = nil
        
        self.sut = DataTaskHandler(
            data: nil,
            response: self.successfulResponse,
            error: nil)
        { response in testResponse = response }
        
        self.sut.execute()
        
        XCTAssertNotNil(testResponse)
        XCTAssertNotNil(testResponse?.failure)
        XCTAssertEqual(testResponse?.failure as? HTTPURLRequest.Error, expectedError)
    }
    
    func test_execute_emptyResponse_callsFailure() {
        let expectedError = HTTPURLRequest.Error.unknownResponse
        var testResponse: Result<DataResponse, Swift.Error>? = nil
        
        self.sut = DataTaskHandler(
            data: Data(),
            response: nil,
            error: nil)
        { response in testResponse = response }
        
        self.sut.execute()
        
        XCTAssertNotNil(testResponse)
        XCTAssertNotNil(testResponse?.failure)
        XCTAssertEqual(testResponse?.failure as? HTTPURLRequest.Error, expectedError)
    }
    
    func test_execute_unsuccessfulHTTPStatusCode_callsFailure() {
        let data = Data()
        let dataResponse = DataResponse(data: data, response: self.unsuccessfulResponse)
        let expectedError = HTTPURLRequest.Error.unsuccessfulHTTPStatusCode(dataResponse)
        var testResponse: Result<DataResponse, Swift.Error>? = nil
        
        self.sut = DataTaskHandler(
            data: data,
            response: self.unsuccessfulResponse,
            error: nil)
        { response in testResponse = response }
        
        self.sut.execute()
        
        XCTAssertNotNil(testResponse)
        XCTAssertNotNil(testResponse?.failure)
        XCTAssertEqual(testResponse?.failure as? HTTPURLRequest.Error, expectedError)
    }
    
    func test_validResponse_callsSuccess() {
        let data = Data()
        let expectedDataResponse = DataResponse(data: data, response: self.successfulResponse)
        var testResponse: Result<DataResponse, Swift.Error>? = nil
        
        self.sut = DataTaskHandler(
            data: data,
            response: self.successfulResponse,
            error: nil)
        { response in testResponse = response }
        
        self.sut.execute()
        
        XCTAssertNotNil(testResponse)
        XCTAssertNil(testResponse?.failure)
        XCTAssertNotNil(testResponse?.success)
        XCTAssertEqual(testResponse?.success, expectedDataResponse)
    }
        
        
}
