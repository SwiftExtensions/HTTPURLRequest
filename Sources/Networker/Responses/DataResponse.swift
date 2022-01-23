import Foundation

/// The raw message body (_or content_) data and
/// the metadata associated with the response to an HTTP protocol URL load request.
public struct DataResponse: Equatable {
    /// The raw message body (_or content_) data.
    public let data: Data
    /// The metadata associated with the response to an HTTP protocol URL load request.
    public let response: HTTPURLResponse
    
    
}

extension DataResponse {
    /// Decodes data and wraps them in DecodableResult.
    /// - Parameters:
    ///   - type: Data type to decode.
    ///   - decoder: An object that decodes instances of a data type from JSON objects.
    /// - Returns: Decoded data wrapped in DecodableResult.
    func decoding<T : Decodable>(type: T.Type, decoder: JSONDecoder) -> HTTPURLRequest.DecodableResult<T> {
        switch self.data.decoding(type: T.self, decoder: decoder) {
        case let .success(decoded):
            let decodableResponse = DecodableResponse(decoded: decoded, response: self.response)
            return .success(decodableResponse)
        case let .failure(error):
            return .failure(error)
        }
    }
    
    
}
