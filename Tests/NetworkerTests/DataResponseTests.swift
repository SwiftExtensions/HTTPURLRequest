import XCTest
@testable import Networker

final class DataResponseTests: XCTestCase {
    let successfulResponse = HTTPURLResponse(url: URL(string: "http://example.com")!, statusCode: 200)!
    var sut: DataResponse!
    
    func test_decoding_correctData_createsSuccessDecodableResult() {
        let jsonData = Data(jsonString.utf8)
        self.sut = DataResponse(data: jsonData, response: self.successfulResponse)
        let actualDecodableResult = self.sut.decoding(type: TestJSON.self, decoder: JSONDecoder())
        let testJSON = try! TestJSON(decoding: jsonData)
        
        XCTAssertEqual(actualDecodableResult.success?.decoded, testJSON)
        XCTAssertNil(actualDecodableResult.failure)
    }
    
    func test_decoding_invalidData_createsFailureDecodableResult() {
        self.sut = DataResponse(data: Data(), response: self.successfulResponse)
        let actualDecodableResult = self.sut.decoding(type: TestJSON.self, decoder: JSONDecoder())
        var expectedError: NSError? = nil
        do {
            _ = try TestJSON(decoding: Data())
        } catch {
            expectedError = error as NSError
        }
        
        XCTAssertNil(actualDecodableResult.success)
        XCTAssertNotNil(actualDecodableResult.failure)
        let actualErrorCode = (actualDecodableResult.failure as NSError?)?.code
        let expectedErrorCode = expectedError?.code
        XCTAssertEqual(actualErrorCode, expectedErrorCode)
    }
    
    
}
