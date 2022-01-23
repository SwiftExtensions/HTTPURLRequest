/// A single name-value pair of HTTP header.
///
/// Example:
/// ```swift
/// let url = URL(string: "http://example.com/")!
/// var urlRequest = URLRequest(url: url)
/// urlRequest.setHTTPHeader(.contentType)
/// let request = HTTPURLRequest(request: urlRequest)
///
/// extension HTTPHeader {
///     static let contentType = HTTPHeader(name: "Content-Type", value: "text/html")
/// }
/// ```
public struct HTTPHeader {
    /// The name of the header field. In keeping with the HTTP RFC, HTTP header field names are case insensitive.
    public var name: String
    /// The value for the header field.
    public var value: String?
    
    /// Initiates a single name-value pair of HTTP header.
    /// - Parameters:
    ///   - name: The name of the header field. In keeping with the HTTP RFC, HTTP header field names are case insensitive.
    ///   - value: The value for the header field.
    /// 
    /// Example:
    /// ```swift
    /// let url = URL(string: "http://example.com/")!
    /// var urlRequest = URLRequest(url: url)
    /// urlRequest.setHTTPHeader(.contentType)
    /// let request = HTTPURLRequest(request: urlRequest)
    ///
    /// extension HTTPHeader {
    ///     static let contentType = HTTPHeader(name: "Content-Type", value: "text/html")
    /// }
    /// ```
    public init(name: String, value: String? = nil) {
        self.name = name
        self.value = value
    }
    

}
