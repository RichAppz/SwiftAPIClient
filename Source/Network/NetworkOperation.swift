//
//  NetworkOperation.swift
//  SimpleAPIClient
//
//  Copyright (c) 2017-2019 RichAppz Limited (https://richappz.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

public enum RequestError: Int, Error {
    case badRequest = 400
    case unauthorised = 401
    case userDisabled = 403
    case notFound = 404
    case methodNotAllowed = 405
    case serverError = 500
    case noConnection = -1009
    case timeOutError = -1001
}

class NetworkOperation: ConcurrentOperation {
    
    // ==========================================
    // MARK: Properties
    // ==========================================
    
    let networkRequest: URL
    let parameters: [String: Any]?
    let completion: OperationResponse?
    var method: HTTPMethod = .get
    
    var session: URLSession?
    
    // ==========================================
    // MARK: Initialization
    // ==========================================
    
    /**
     Creates a NetworkOperation with the parameters required for the endpoint.
     - Parameter request: URLConvertible - endpoint
     - Parameter config: URLSessionConfiguration - configuration of the request
     - Parameter params: Dictionary<String: Any> - additional parameters
     - Parameter encoding: ParameterEncoding? - Almofire Parameter Encoding type
     - Parameter completionHandler:  <Optional>OperationResponse
     */
    init(
        request: URL,
        config: URLSessionConfiguration,
        params: [String: Any]?,
        completionHandler: OperationResponse?) {
            networkRequest = request
            completion = completionHandler
            parameters = params
            super.init()
            
            session = URLSession(
                configuration: .default,
                delegate: self,
                delegateQueue: OperationQueue.current
            )
        }
    
    // ==========================================
    // MARK: Overrides
    // ==========================================
    
    override func main() {
        var request = URLRequest(url: networkRequest)
        
        if
            let parameters = parameters,
            let data = try? JSONSerialization.data(
                withJSONObject: parameters,
                options: .prettyPrinted) {
            
            if
                var components = URLComponents(string: networkRequest.absoluteString),
                method == .get {
                
                let existingItems = components.queryItems ?? []
                let mappedItems = parameters.map { (key, value) in
                    URLQueryItem(name: key, value: value as? String)
                }
                let queryItems = existingItems + mappedItems
                
                components.queryItems = queryItems
                components.percentEncodedQuery = components
                    .percentEncodedQuery?
                    .replacingOccurrences(
                        of: "+",
                        with: "%2B"
                    )
                
                guard let url = components.url else { return }
                request = URLRequest(url: url)
            } else {
                request.httpBody = data
            }
        }
        
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        session?.dataTask(with: request) { data, response, error in
            let response = response as? HTTPURLResponse
            
            guard
                let data = data,
                response?.statusCode ?? 0 >= 200 &&
                error == nil else {
                
                self.completion?(
                    Response(
                        data: data,
                        headers: response?.allHeaderFields as? [String: Any],
                        error: error
                    )
                )
                return
            }
            
            let allHeaderFields = response?.allHeaderFields as? [String: Any]
            func complete(data: Data? = nil) {
                self.completion?(
                    Response(
                        data: data,
                        headers: allHeaderFields,
                        error: error
                    )
                )
            }
            
            do {
                guard
                    let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                        complete()
                        return
                    }
                
                complete(data: prettyJsonData)
            } catch {
                complete()
            }
        }.resume()
    }
    
    override func cancel() {
        session?.invalidateAndCancel()
        super.cancel()
    }
    
}

extension NetworkOperation: URLSessionDelegate { }
