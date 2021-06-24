import XCTest
@testable import Networker

class URLRequestTests: XCTestCase {
    let url = URL(string: "http://example.com/")!
    var sut: URLRequest!

    func test_setHTTPHeader_setsCorrectHeader() {
        self.sut = URLRequest(url: self.url)
        let header = HTTPHeader(name: "Content-Type", value: "text/html")
        self.sut.setHTTPHeader(header)
        
        XCTAssertEqual(self.sut.allHTTPHeaderFields?[header.name], header.value)
    }
    
    func test_setHTTPHeaders_setsCorrectHeaders() {
        self.sut = URLRequest(url: self.url)
        let contentType = HTTPHeader(name: "Content-Type", value: "text/html")
        let contentLanguage = HTTPHeader(name: "Content-Language", value: "ru")
        self.sut.setHTTPHeaders([contentType, contentLanguage])
        
        XCTAssertEqual(self.sut.allHTTPHeaderFields?[contentType.name], contentType.value)
        XCTAssertEqual(self.sut.allHTTPHeaderFields?[contentLanguage.name], contentLanguage.value)
    }
    
    
}

extension HTTPHeader {
    static let contentLanguage = HTTPHeader(name: "Content-Language", value: "ru")
    static let contentType = HTTPHeader(name: "Content-Type", value: "text/html")
    
    
}
