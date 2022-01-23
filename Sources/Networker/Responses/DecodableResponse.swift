import Foundation

/// The decoded message body (_or content_) data and
/// the metadata associated with the response to an HTTP protocol URL load request.
public struct DecodableResponse<T: Decodable> {
    /// The decoded message body (_or content_) data.
    public let decoded: T
    /// The metadata associated with the response to an HTTP protocol URL load request.
    public let response: HTTPURLResponse
    
    
}
