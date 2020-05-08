//
//  RequestModel.swift
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

public struct RequestModel {
    
    let endpoint: String
    let endpointParams: [Any]?
    let params: [String: Any]
    let storageType: StorageType
    let storageKeyAddition: String?
    let notification: Notification.Name?
    
    var isRetry: Bool = false
    
    public init(
        endpoint: String = "",
        endpointParams: [Any]? = nil,
        params: [String: Any] = [:],
        storageType: StorageType = .none,
        storageKeyAddition: String? = nil,
        notification: Notification.Name? = nil) {
        
        self.endpoint = endpoint
        self.endpointParams = endpointParams
        self.params = params
        self.storageType = storageType
        self.storageKeyAddition = storageKeyAddition
        self.notification = notification
    }
    
    mutating func retry() {
        isRetry = true
    }
    
}

extension RequestModel {
    
    var fullPath: String {
        return .fullPath(endpoint: endpoint, endpointParams: endpointParams)
    }
    
}
