//
//  File.swift
//  
//
//  Created by Лайм HD on 29.06.2021.
//

import Foundation

/// Handles URL session data task.
struct DataTaskHandler {
    /// The data returned by the server.
    let data: Data?
    /// An object that provides response metadata, such as HTTP headers and status code.
    /// If you are making an HTTP or HTTPS request, the returned object is actually an HTTPURLResponse object.
    let response: URLResponse?
    /// An error object that indicates why the request failed, or nil if the request was successful.
    let error: Error?
    /// The completion handler to call when the load request is complete. This handler is executed on the delegate queue.
    let completionHandler: HTTPURLRequest.Completion
    
    /// Executes URL session data task handling.
    func execute() {
        if let error = error {
            self.completionHandler(.failure(error))
            return
        }
        
        guard let data = data else {
            let error = HTTPURLRequest.Error.emptyData
            self.completionHandler(.failure(error))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            let error = HTTPURLRequest.Error.unknownResponse
            self.completionHandler(.failure(error))
            return
        }
        
        let dataResponse = DataResponse(data: data, response: httpResponse)
        if (200...299).contains(httpResponse.statusCode) {
            self.completionHandler(.success(dataResponse))
        } else {
            let error = HTTPURLRequest.Error.unsuccessfulHTTPStatusCode(dataResponse)
            self.completionHandler(.failure(error))
        }
    }
    
    
}
