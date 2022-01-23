#if !os(macOS)
import UIKit

/// The decoded message body (_or content_) image data and
/// the metadata associated with the response to an HTTP protocol URL load request.
public struct ImageResponse {
    /// The decoded message body (_or content_) image data.
    public let image: UIImage
    /// The metadata associated with the response to an HTTP protocol URL load request.
    public let response: HTTPURLResponse
    
    
}
#endif
