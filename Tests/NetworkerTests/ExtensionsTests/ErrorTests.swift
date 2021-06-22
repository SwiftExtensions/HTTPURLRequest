import XCTest
@testable import Networker

class ErrorTests: XCTestCase {
    var sut: Error!

    func test_httpURLRequest_createsCorrectValue() {
        self.sut = HTTPURLRequest.Error.emptyPath
        
        XCTAssertEqual(self.sut.httpURLRequest, HTTPURLRequest.Error.emptyPath)
    }
}
