import Foundation

public extension URLRequest {
    /// Sets a HTTP header.
    mutating func setHTTPHeader(_ header: HTTPHeader) {
        self.setValue(header.value, forHTTPHeaderField: header.name)
    }
    
    /// Sets a HTTP headers.
    mutating func setHTTPHeaders(_ headers: [HTTPHeader]) {
        headers.forEach { self.setHTTPHeader($0) }
    }
    
    
}
