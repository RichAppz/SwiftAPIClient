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
import Alamofire

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
    
    //==========================================
    // MARK: Properties
    //==========================================
    
    let networkRequest: URLConvertible
    let parameters: [String: Any]?
    let completion: OperationResponse?
    var method: HTTPMethod = .get
    
    var manager: Session?
    weak var request: Alamofire.Request?
    
    //==========================================
    // MARK: Initialization
    //==========================================
    
    /**
         Creates a NetworkOperation with the parameters required for the endpoint.
     
         - Parameter request:                    URLConvertible - endpoint
         - Parameter config:                      URLSessionConfiguration - configuration of the request
         - Parameter params:                    Dictionary<String: Any> - additional parameters
         - Parameter completionHandler:  <Optional>OperationResponse
         */
    init(request: URLConvertible, config: URLSessionConfiguration, params: [String: Any]?, completionHandler: OperationResponse?) {
        networkRequest = request
        completion = completionHandler
        parameters = params
        manager = Alamofire.Session(configuration: config)
        super.init()
    }
    
    //==========================================
    // MARK: Overrides
    //==========================================
    
    override func main() {
        var encoding: ParameterEncoding = URLEncoding.default
        if method == .post || method == .put || method == .patch {
            encoding = JSONEncoding.default
        }
        
        let queue = DispatchQueue(label: kResponseQueue, qos: .utility, attributes: [.concurrent])
        request = manager?
            .request(networkRequest, method: method, parameters: parameters, encoding: encoding)
            .response(
                queue: queue,
                responseSerializer: DataResponseSerializer(),
                completionHandler: { (response) in
                    if let statusCode = response.response?.statusCode, statusCode > 200 {
                        let responseData = response.data
                        self.completion?(Response.init(
                            data: responseData,
                            headers: response.response?.allHeaderFields as? [String: Any],
                            error: response.error ?? NSError(
                                domain: kRequestErrorDomain,
                                code: statusCode,
                                userInfo: responseData?.json ?? [:]
                                ) as Error
                        ))
                        return
                    }
                    
                    self.completion?(Response.init(
                        data: response.data,
                        headers: response.response?.allHeaderFields as? [String: Any],
                        error: response.error
                    ))
                    
                    self.completeOperation()
            })
    }
    
    override func cancel() {
        request?.cancel()
        super.cancel()
    }
    
}
