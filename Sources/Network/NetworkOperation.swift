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
import Accessibility

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

public enum NetworkOperationType {
    /// Standard network requests, this is defaulted so unless you want upload or download you don't need to change
    case standard
    /// Set this and the response will include a `fileStoreUrl` if the file downloaded successfully
    case fileDownload
}

class NetworkOperation: ConcurrentOperation {
    
    // ==========================================
    // MARK: Properties
    // ==========================================
    
    let networkRequest: URL
    let parameters: [String: Any]?
    let completion: OperationResponse?
    let allHTTPHeaderFields: [String: String]
    let type: NetworkOperationType
    let upload: FileUpload?
    var method: HTTPMethod = .get
    
    var session: URLSession?
    
    // ==========================================
    // MARK: Initialization
    // ==========================================
    
    /**
     Creates a NetworkOperation with the parameters required for the endpoint.
     - Parameter request: URLConvertible - endpoint
     - Parameter requestType: NetworkOperationType = .standard
     - Parameter config: URLSessionConfiguration - configuration of the request
     - Parameter params: Dictionary<String: Any> - additional parameters
     - Parameter encoding: ParameterEncoding? - Almofire Parameter Encoding type
     - Parameter completionHandler:  <Optional>OperationResponse
     */
    init(
        request: URL,
        requestType: NetworkOperationType = .standard,
        config: URLSessionConfiguration,
        headers: [String: String],
        params: [String: Any]?,
        fileUpload: FileUpload? = nil,
        completionHandler: OperationResponse?) {
            networkRequest = request
            type = requestType
            completion = completionHandler
            allHTTPHeaderFields = headers
            parameters = params
            upload = fileUpload
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
    
    // swiftlint:disable cyclomatic_complexity function_body_length
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
                var mappedItems: [URLQueryItem] = []
                
                parameters.forEach { (key, value) in
                    switch value {
                    case let value as String:
                        mappedItems.append(
                            URLQueryItem(name: key, value: value)
                        )
                    case let value as Int:
                        mappedItems.append(
                            URLQueryItem(name: key, value: "\(value)")
                        )
                    case let values as [String]:
                        mappedItems.append(
                            contentsOf: values.compactMap {
                                return URLQueryItem(name: String(format: "%@[]", key), value: $0)
                            }
                        )
                    default:
                        break
                    }
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
        request.allHTTPHeaderFields = allHTTPHeaderFields
        
        if let upload = upload {
            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            var requestData = Data()
            requestData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            let contentDisposition = "Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n"
            requestData.append(
                String(
                    format: contentDisposition,
                    upload.paramName,
                    upload.fullFileName).data(using: .utf8)!
            )
            
            let contentType = "Content-Type: %@\r\n\r\n"
            requestData.append(
                String(
                    format: contentType,
                    upload.mimeType).data(using: .utf8)!
            )
            requestData.append(upload.data)
            requestData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            
            session?.uploadTask(
                with: request,
                from: requestData) { data, response, error in
                    let response = response as? HTTPURLResponse
                    let allHeaderFields = response?.allHeaderFields as? [String: Any]
                    
                    func complete(data: Data? = nil) {
                        self.completion?(
                            Response(
                                data: data,
                                headers: nil,
                                error: error
                            )
                        )
                    }
                    
                    if let statusCode = response?.statusCode, statusCode >= 400 {
                        self.completion?(
                            Response(
                                data: data,
                                headers: allHeaderFields,
                                error: NSError(
                                    domain: "com.swiftapiclient.network.error",
                                    code: statusCode,
                                    userInfo: data?.json
                                )
                            )
                        )
                        return
                    }
                    
                    do {
                        guard let data = data else {
                            complete()
                            return
                        }
                        
                        var jsonObject: Any? = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                        if jsonObject == nil {
                            jsonObject = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
                        }
                        
                        guard
                            let jsonObject = jsonObject,
                            let prettyJsonData = try? JSONSerialization.data(
                            withJSONObject: jsonObject,
                            options: .prettyPrinted) else {
                                complete()
                                return
                            }
                        
                        complete(data: prettyJsonData)
                    } catch {
                        complete()
                    }
            }.resume()
            return
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        session?.dataTask(with: request) { data, response, error in
            let response = response as? HTTPURLResponse
            let allHeaderFields = response?.allHeaderFields as? [String: Any]
            
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
            
            if let statusCode = response?.statusCode, statusCode >= 400 {
                self.completion?(
                    Response(
                        data: data,
                        headers: allHeaderFields,
                        error: NSError(
                            domain: "com.swiftapiclient.network.error",
                            code: statusCode,
                            userInfo: data.json
                        )
                    )
                )
                return
            }
            
            func complete(data: Data? = nil) {
                self.completion?(
                    Response(
                        data: data,
                        headers: allHeaderFields,
                        error: error
                    )
                )
            }
            
            switch self.type {
            case .standard:
                do {
                    var jsonObject: Any? = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    if jsonObject == nil {
                        jsonObject = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
                    }
                    
                    guard
                        let jsonObject = jsonObject,
                        let prettyJsonData = try? JSONSerialization.data(
                            withJSONObject: jsonObject,
                            options: .prettyPrinted) else {
                                complete()
                                return
                            }
                    
                    complete(data: prettyJsonData)
                } catch {
                    complete()
                }
            case .fileDownload:
                guard let filename = response?.suggestedFilename else {
                    self.completion?(
                        Response(
                            data: data,
                            headers: response?.allHeaderFields as? [String: Any],
                            error: error
                        )
                    )
                    return
                }
            
                let fileStoreUrl = URL(fileURLWithPath: NSTemporaryDirectory())
                    .appendingPathComponent(filename)
                
                do {
                    try data.write(to: fileStoreUrl, options: Data.WritingOptions.atomic)
                    self.completion?(
                        Response(
                            data: data,
                            fileStoreUrl: fileStoreUrl,
                            headers: response?.allHeaderFields as? [String: Any],
                            error: error
                        )
                    )
                } catch {
                    self.completion?(
                        Response(
                            data: data,
                            headers: response?.allHeaderFields as? [String: Any],
                            error: error
                        )
                    )
                }
            }
            
        }.resume()
    }
    
    private func jsonString(from value: [Any]) -> String? {
        if
            JSONSerialization.isValidJSONObject(value),
            let data = try? JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed),
            let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String {
            return string
        }
    
        return nil
    }
    
    override func cancel() {
        session?.invalidateAndCancel()
        super.cancel()
    }
    
}

extension NetworkOperation: URLSessionDelegate { }
