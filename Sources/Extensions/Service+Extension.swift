//
//  Service+Extension.swift
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

extension Service {
    
    // ================================================================================
    // MARK: Standardized Helpers
    // ================================================================================
    
    /**
     Standard `GET` response to the server
     - Parameter request: RequestModel
     - Parameter request: ObjRequestModel<T>
     */
    public func stdGetRequest<T: Model>(
        _ request: RequestModel,
        completion: ModelObjectCompletionBlock<T>? = nil) {
        
        let path: String = request.fullPath
        
        let closure = Closure(url: path, params: request.params, blockObj: completion)
        let hasRequested = ClosureService.contains(closure)
        if hasRequested && !request.isRetry {
            return
        }
        
        #if os(iOS) || os(macOS)
        // Check network connection
        let hasConnection = checkConnection(
            storageKeyAddition: request.storageKeyAddition,
            notification: request.notification,
            requiresConnection: request.storageType == .none,
            arrayResponse: false,
            closure: closure)
        if !hasConnection { return }
        #endif
        
        get(
            Request(
                endpoint: path,
                parameters: request.params
            )
        ) { (response) in
            var mappingError: Error?
            var object: T?
            do {
                object = try StorageClient.map(
                    object: response.data,
                    storageKey: request.storageKeyAddition,
                    storageType: request.storageType)
            } catch {
                mappingError = response.error ?? error
                debugPrint(error)
            }
            
            DispatchQueue.main.async {
                ClosureService.closures(closure).forEach({
                    $0.blockObj?(object, mappingError ?? response.error)
                })
                
                if let notification = request.notification {
                    NotificationCenter.default.post(name: notification, object: object)
                }
            }
        }
    }
    
    /**
     Standard `GET` response to the server
     - Parameter request: RequestModel
     - Parameter request: ArrRequestModel<T>
     */
    public func stdGetRequest<T: Model>(
        _ request: RequestModel,
        completion: ModelArrayCompletionBlock<T>? = nil) {
        
        let path: String = request.fullPath
        
        let closure = Closure(url: path, params: request.params, blockArr: completion)
        let hasRequested = ClosureService.contains(closure)
        if hasRequested && !request.isRetry {
            return
        }
        
        #if os(iOS) || os(macOS)
        // Check network connection
        let hasConnection = checkConnection(
            storageKeyAddition: request.storageKeyAddition,
            notification: request.notification,
            requiresConnection: request.storageType == .none,
            arrayResponse: true,
            closure: closure)
        if !hasConnection { return }
        #endif
        
        get(
            Request(
                endpoint: path,
                parameters: request.params
            )
        ) { (response) in
            var mappingError: Error?
            var object: [T]?
            do {
                object = try StorageClient.map(
                    object: response.data,
                    storageKey: request.storageKeyAddition,
                    storageType: request.storageType)
            } catch {
                mappingError = response.error ?? error
            }
            
            DispatchQueue.main.async {
                ClosureService.closures(closure).forEach({
                    $0.blockArr?(object, mappingError ?? response.error)
                })
                
                if let notification = request.notification {
                    NotificationCenter.default.post(name: notification, object: object)
                }
            }
        }
    }
    
    /**
     Standard `POST` response to the server
     - Parameter request: ObjRequestModel<T>
     */
    public func stdPostRequest<T: Model>(
        _ request: RequestModel,
        completion: ModelObjectCompletionBlock<T>? = nil) {
        
        let path: String = request.fullPath
        
        // Create closure
        let closure = Closure(url: path, params: request.params, blockObj: completion)
        let hasRequested = ClosureService.contains(closure)
        if hasRequested && !request.isRetry {
            return
        }
        
        #if os(iOS) || os(macOS)
        // Check network connection
        let hasConnection = checkConnection(
            storageKeyAddition: request.storageKeyAddition,
            notification: request.notification,
            requiresConnection: request.storageType == .none,
            arrayResponse: false,
            closure: closure)
        if !hasConnection { return }
        #endif
        
        post(
            Request(
                endpoint: path,
                parameters: request.params
            )
        ) { (response) in
            var mappingError: Error?
            var object: T?
            do {
                object = try StorageClient.map(
                    object: response.data,
                    storageKey: request.storageKeyAddition,
                    storageType: request.storageType
                )
            } catch {
                mappingError = response.error ?? error
            }
            
            DispatchQueue.main.async {
                ClosureService.closures(closure).forEach({
                    $0.blockObj?(object, mappingError ?? response.error)
                })
                
                if let notification = request.notification {
                    NotificationCenter.default.post(name: notification, object: object)
                }
            }
        }
    }
    
    /**
     Standard `POST` response to the server
     - Parameter request: ArrRequestModel<T>
     */
    public func stdPostRequest<T: Model>(
        _ request: RequestModel,
        completion: ModelArrayCompletionBlock<T>? = nil) {
        
        let path: String = request.fullPath
        
        let closure = Closure(url: path, params: request.params, blockArr: completion)
        let hasRequested = ClosureService.contains(closure)
        if hasRequested && !request.isRetry {
            return
        }
        
        #if os(iOS) || os(macOS)
        // Check network connection
        let hasConnection = checkConnection(
            storageKeyAddition: request.storageKeyAddition,
            notification: request.notification,
            requiresConnection: request.storageType == .none,
            arrayResponse: true,
            closure: closure)
        if !hasConnection { return }
        #endif
        
        post(
            Request(
                endpoint: path,
                parameters: request.params
            )
        ) { (response) in
            var mappingError: Error?
            var object: [T]?
            do {
                object = try StorageClient.map(
                    object: response.data,
                    storageKey: request.storageKeyAddition,
                    storageType: request.storageType)
            } catch {
                mappingError = response.error ?? error
            }
            
            DispatchQueue.main.async {
                ClosureService.closures(closure).forEach({
                    $0.blockArr?(object, mappingError ?? response.error)
                })
                
                if let notification = request.notification {
                    NotificationCenter.default.post(name: notification, object: object)
                }
            }
        }
    }
    
    /**
     Standard `Delete` response to the server
     - Parameter request: ErrRequestModel
     */
    public func stdDeleteRequest(
        _ request: RequestModel,
        completion: ((Error?) -> Void)? = nil) {
        
        let path: String = request.fullPath
        
        #if os(iOS) || os(macOS)
        // Check network connection
        let hasConnection = checkConnection(
            storageKeyAddition: request.storageKeyAddition,
            notification: request.notification,
            arrayResponse: true)
        if !hasConnection { return }
        #endif
        
        delete(
            Request(
                endpoint: path,
                parameters: request.params
            )
        ) { (response) in
            DispatchQueue.main.async {
                completion?(response.error)
            }
        }
    }
    
    /**
     Standard `PUT` response to the server
     - Parameter request: ErrRequestModel
     */
    public func stdPutRequest(
        _ request: RequestModel,
        completion: ((Error?) -> Void)? = nil) {
        
        let path: String = request.fullPath
        
        #if os(iOS) || os(macOS)
        // Check network connection
        let hasConnection = checkConnection(
            storageKeyAddition: request.storageKeyAddition,
            notification: request.notification,
            arrayResponse: true)
        if !hasConnection { return }
        #endif
        
        put(
            Request(
                endpoint: path,
                parameters: request.params
            )
        ) { (response) in
            DispatchQueue.main.async {
                completion?(response.error)
            }
        }
    }
    
    /**
     Standard `PUT` response to the server
     - Parameter request: ObjRequestModel<T>
     */
    public func stdPutRequest<T: Model>(
        _ request: RequestModel,
        completion: ModelObjectCompletionBlock<T>? = nil) {
        
        let path: String = request.fullPath
        
        // Create closure
        let closure = Closure(url: path, params: request.params, blockObj: completion)
        let hasRequested = ClosureService.contains(closure)
        if hasRequested && !request.isRetry {
            return
        }
        
        #if os(iOS) || os(macOS)
        // Check network connection
        let hasConnection = checkConnection(
            storageKeyAddition: request.storageKeyAddition,
            notification: request.notification,
            requiresConnection: request.storageType == .none,
            arrayResponse: false,
            closure: closure)
        if !hasConnection { return }
        #endif
        
        put(
            Request(
                endpoint: path,
                parameters: request.params
            )
        ) { (response) in
            var mappingError: Error?
            var object: T?
            do {
                object = try StorageClient.map(
                    object: response.data,
                    storageKey: request.storageKeyAddition,
                    storageType: request.storageType
                )
            } catch {
                mappingError = response.error ?? error
            }
            
            DispatchQueue.main.async {
                ClosureService.closures(closure).forEach({
                    $0.blockObj?(object, mappingError ?? response.error)
                })
                
                if let notification = request.notification {
                    NotificationCenter.default.post(name: notification, object: object)
                }
            }
        }
    }
    
    /**
     Standard `PUT` response to the server
     - Parameter request: ArrRequestModel<T>
     */
    public func stdPutRequest<T: Model>(
        _ request: RequestModel,
        completion: ModelArrayCompletionBlock<T>? = nil) {
        
        let path: String = request.fullPath
        
        let closure = Closure(url: path, params: request.params, blockArr: completion)
        let hasRequested = ClosureService.contains(closure)
        if hasRequested && !request.isRetry {
            return
        }
        
        #if os(iOS) || os(macOS)
        // Check network connection
        let hasConnection = checkConnection(
            storageKeyAddition: request.storageKeyAddition,
            notification: request.notification,
            requiresConnection: request.storageType == .none,
            arrayResponse: true,
            closure: closure)
        if !hasConnection { return }
        #endif
        
        put(
            Request(
                endpoint: path,
                parameters: request.params
            )
        ) { (response) in
            var mappingError: Error?
            var object: [T]?
            do {
                object = try StorageClient.map(
                    object: response.data,
                    storageKey: request.storageKeyAddition,
                    storageType: request.storageType)
            } catch {
                mappingError = response.error ?? error
            }
            
            DispatchQueue.main.async {
                ClosureService.closures(closure).forEach({
                    $0.blockArr?(object, mappingError ?? response.error)
                })
                
                if let notification = request.notification {
                    NotificationCenter.default.post(name: notification, object: object)
                }
            }
        }
    }
    
    #if os(iOS) || os(macOS)
    /**
     Check to see if there is a network connection - if there is not it will complete the closures available for the request
     - Parameter notification: Notification.Name? = nil
     - Parameter arrayResponse: Bool
     - Parameter closure: Closure<T>
     - Returns: Bool
     */
    private func checkConnection<T: Model>(
        storageKeyAddition: String? = nil,
        notification: Notification.Name? = nil,
        requiresConnection: Bool,
        arrayResponse: Bool,
        closure: Closure<T>) -> Bool {
        
        if !NetworkStatusService.hasConnection {
            DispatchQueue.main.async {
                if arrayResponse {
                    guard !requiresConnection else {
                        ClosureService.closures(closure).forEach({
                            $0.blockArr?(nil, ServiceRequestError.hasNoConnection)
                        })
                        return
                    }
                    
                    let completionBlock: (([T]?) -> Void) = { object in
                        ClosureService.closures(closure).forEach({
                            $0.blockArr?(object, nil)
                        })
                        
                        if let notification = notification {
                            NotificationCenter.default.post(name: notification, object: object)
                        }
                    }
                    
                    try? StorageClient.retrieve(storageKey: storageKeyAddition, completion: completionBlock)
                    
                } else {
                    guard !requiresConnection else {
                        ClosureService.closures(closure).forEach({
                            $0.blockObj?(nil, ServiceRequestError.hasNoConnection)
                        })
                        return
                    }
                    
                    let completionBlock: ((T?) -> Void) = { object in
                        ClosureService.closures(closure).forEach({
                            $0.blockObj?(object, nil)
                        })
                        
                        if let notification = notification {
                            NotificationCenter.default.post(name: notification, object: object)
                        }
                    }
                    
                    try? StorageClient.retrieve(storageKey: storageKeyAddition, completion: completionBlock)
                    
                }
            }
            return false
        }
        return true
    }
    
    /**
     Check to see if there is a network connection - if there is not it will complete the closures available for the request
     - Parameter notification: Notification.Name? = nil
     - Parameter arrayResponse: Bool
     - Returns: Bool
     */
    private func checkConnection(
        storageKeyAddition: String? = nil,
        notification: Notification.Name? = nil,
        arrayResponse: Bool) -> Bool {
        return NetworkStatusService.hasConnection
    }
    #endif
    
}
