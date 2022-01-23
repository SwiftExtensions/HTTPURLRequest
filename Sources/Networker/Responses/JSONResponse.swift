import Foundation

/// The decoded message body (_or content_) [JSON](https://www.json.org/json-en.html) data and
/// the metadata associated with the response to an HTTP protocol URL load request.
///
/// More info, see: [Working with JSON in Swift](https://developer.apple.com/swift/blog/?id=37).
public struct JSONResponse {
    /// The decoded message body (_or content_) [JSON](https://www.json.org/json-en.html) data.
    ///
    /// More info, see: [Working with JSON in Swift](https://developer.apple.com/swift/blog/?id=37).
    public let json: Any
    /// The metadata associated with the response to an HTTP protocol URL load request.
    public let response: HTTPURLResponse
    
    
}
