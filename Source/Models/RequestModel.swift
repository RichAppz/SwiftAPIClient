//
//  RequestModel.swift
//  NetworkCore
//
//  Created by Rich Mucha on 31/03/2020.
//  Copyright © 2020 Checkfer. All rights reserved.
//

import Foundation

public struct RequestModel {
    
    let endpoint: String
    let endpointParam: String?
    let params: [String: Any]
    let storageType: StorageType
    let storageKeyAddition: String?
    let notification: Notification.Name?
    
    var isRetry: Bool = false
    
    public init(
        endpoint: String = "",
        endpointParam: String? = nil,
        params: [String: Any] = [:],
        storageType: StorageType = .none,
        storageKeyAddition: String? = nil,
        notification: Notification.Name? = nil) {
        
        self.endpoint = endpoint
        self.endpointParam = endpointParam
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
        return .fullPath(endpoint: endpoint, endpointParam: endpointParam)
    }
    
}
