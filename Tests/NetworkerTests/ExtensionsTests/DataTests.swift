import XCTest
@testable import Networker

class DataTests: XCTestCase {
    var sut: Data!

    func test_utf8String_createsCorrectString() {
        let string = "TEST"
        self.sut = Data(string.utf8)
        
        XCTAssertEqual(string, self.sut.utf8String)
    }
    
    func test_image_createsCorrectImage() {
        let image = UIImage.create(with: .black, size: CGSize(width: 10, height: 10))
        self.sut = image?.pngData()
        let actualImage = UIImage(data: self.sut)
        let expectedImage = self.sut.image
        
        XCTAssertNotNil(actualImage)
        XCTAssertEqual(actualImage?.size, expectedImage?.size)
    }
    
    func test_json_invalidJSON_createsErrorValue() {
        self.sut = Data("INVALID".utf8)
        
        XCTAssertNil(self.sut.json().success)
        XCTAssertNotNil(self.sut.json().failure)
    }
    
    func test_json_correctJSON_createsCorrectValue() {
        self.sut = Data(jsonString.utf8)
        let actualJSON = self.sut.json().success as? [String: [String]]
        let expectedJSON = try? JSONSerialization.jsonObject(with: self.sut) as? [String: [String]]
        
        XCTAssertNotNil(actualJSON)
        XCTAssertNil(self.sut.json().failure)
        XCTAssertEqual(actualJSON, expectedJSON)
    }
    
    func test_decoding_invalidJSON_createsCorrectDecodable() {
        self.sut = Data("INVALID".utf8)
        let actualTestJSON = self.sut.decoding(type: TestJSON.self)
        
        XCTAssertNil(actualTestJSON.success)
        XCTAssertNotNil(actualTestJSON.failure)
    }
    
    func test_decoding_correctJSON_createsCorrectDecodable() {
        self.sut = Data(jsonString.utf8)
        let actualTestJSON = self.sut.decoding(type: TestJSON.self)
        let expectedTestJSON = try? TestJSON(decoding: self.sut)
        
        XCTAssertNotNil(actualTestJSON.success)
        XCTAssertNil(actualTestJSON.failure)
        XCTAssertEqual(actualTestJSON.success, expectedTestJSON)
    }
}
