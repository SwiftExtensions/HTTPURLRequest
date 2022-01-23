import Foundation

public extension HTTPURLRequest {
    /// HTTPURLRequest error.
    enum Error: Swift.Error, Equatable {
        /// URL string is empty.
        case emptyPath
        /// Invalid path for URL.
        case invalidPath(_ path: String)
        /// There is no data in the server response.
        case emptyData
        /// Server response was not recognized.
        case unknownResponse
        /// Unsuccessful HTTP status code.
        case unsuccessfulHTTPStatusCode(_ dataResponse: DataResponse)
        /// Unsupported data for image to initialize.
        case invalidImageData
        
        /// Unsuccessful HTTP status code data.
        public var unsuccessfulHTTPStatusCodeData: DataResponse? {
            if case let Error.unsuccessfulHTTPStatusCode(httpData) = self {
                return httpData
            }
            
            return nil
        }
    }
    
    
}

// MARK: - LocalizedError

extension HTTPURLRequest.Error: LocalizedError {
    /// Text representation of ``HTTPURLRequest`` error.
    public var errorDescription: String? {
        switch self {
        case .emptyPath:
            let key = "String path is empty."
            return NSLocalizedString(key, comment: "Path is empty.")
        case let .invalidPath(path):
            let key = "Invalid path for URL: \(path)."
            return NSLocalizedString(key, comment: "Invalid path for URL.")
        case .emptyData:
            let key = "There is no data in the server response."
            return NSLocalizedString(key, comment: "No data responses.")
        case .unknownResponse:
            let key = "Server response was not recognized."
            return NSLocalizedString(key, comment: "Unable to recognize the response.")
        case let .unsuccessfulHTTPStatusCode(httpData):
            let statusCode = httpData.response.localizedStatusCode
            let key = "Unsuccessful HTTP status code: \(statusCode)."
            return NSLocalizedString(key, comment: statusCode)
        case .invalidImageData:
            let key = "Unsupported data for image to initialize."
            return NSLocalizedString(key, comment: "Invalid image data.")
        }
        
        
    }
    
    
}
