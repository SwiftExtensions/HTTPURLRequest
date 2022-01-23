import Foundation

/// The decoded message body (_or content_) data and
/// the metadata associated with the response to an HTTP protocol URL load request.
///
/// More info see:
/// [Encoding and Decoding Custom Types](https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types).
public struct DecodableResponse<T: Decodable> {
    /// The decoded message body (_or content_) data.
    ///
    /// More info see:
    /// [Encoding and Decoding Custom Types](https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types).
    public let decoded: T
    /// The metadata associated with the response to an HTTP protocol URL load request.
    public let response: HTTPURLResponse
    
    
}
