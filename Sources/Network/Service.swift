//
//  Service.swift
//  SwiftAPIClient
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

public typealias OperationResponse = (Response) -> Void

public enum ServiceRequestError: Error {
    case authenticationFailed
    case authenticationNotRequired
    case hasNoConnection
}

public enum HTTPMethod: String {
    case get = "GET"
    case delete = "DELETE"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
}

public protocol Service {
    
    // ==========================================
    // MARK: Properties
    // ==========================================
    
    var rootURL: String { get }
    var headers: [String: String] { get set }
    var networkQueue: OperationQueue { get }
    
    // ==========================================
    // MARK: Functions
    // ==========================================
    
    func get(_ request: Request, completion: OperationResponse?)
    func post(_ request: Request, completion: OperationResponse?)
    func delete(_ request: Request, completion: OperationResponse?)
    func put(_ request: Request, completion: OperationResponse?)
    func patch(_ request: Request, completion: OperationResponse?)
    
}

extension Service {
    
    public func makeRequest(
        _ method: HTTPMethod,
        request: Request,
        completion: OperationResponse? = nil) {
            
            guard
                let url = "\(request.rootUrl ?? rootURL)\(request.endpoint)".asURL
                else { return }
            
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = headers
            configuration.timeoutIntervalForRequest = 20
            configuration.timeoutIntervalForResource = 20
            
            let operation = NetworkOperation(
                request: url,
                requestType: request.operationType,
                config: configuration,
                headers: headers,
                params: request.parameters,
                fileUpload: request.upload,
                completionHandler: completion
            )
            operation.method = method
            operation.queuePriority = request.priority
            operation.qualityOfService = request.qualityOfService
            networkQueue.addOperation(operation)
        }
    
}
