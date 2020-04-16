//
//  Service+Extension.swift
//  NetworkCore
//
//  Created by Rich Mucha on 31/03/2020.
//  Copyright © 2020 Checkfer. All rights reserved.
//

import Foundation
import Alamofire

extension Service {
    
    //================================================================================
    // MARK: Standardized Helpers
    //================================================================================
    
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
        
        // Check network connection
        let hasConnection = checkConnection(
            storageKeyAddition: request.storageKeyAddition,
            notification: request.notification,
            arrayResponse: false,
            closure: closure)
        if !hasConnection { return }
        
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
        
        // Check network connection
        let hasConnection = checkConnection(
            storageKeyAddition: request.storageKeyAddition,
            notification: request.notification,
            arrayResponse: true,
            closure: closure)
        if !hasConnection { return }
        
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
        
        // Check network connection
        let hasConnection = checkConnection(
            storageKeyAddition: request.storageKeyAddition,
            notification: request.notification,
            arrayResponse: false,
            closure: closure)
        if !hasConnection { return }
        
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
        
        // Check network connection
        let hasConnection = checkConnection(
            storageKeyAddition: request.storageKeyAddition,
            notification: request.notification,
            arrayResponse: true,
            closure: closure)
        if !hasConnection { return }
        
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
        
        // Check network connection
        let hasConnection = checkConnection(
            storageKeyAddition: request.storageKeyAddition,
            notification: request.notification,
            arrayResponse: true)
        if !hasConnection { return }
        
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
     Standard `Put` response to the server
     - Parameter request: ErrRequestModel
     */
    public func stdPutRequest(
        _ request: RequestModel,
        completion: ((Error?) -> Void)? = nil) {
        
        let path: String = request.fullPath
        
        // Check network connection
        let hasConnection = checkConnection(
            storageKeyAddition: request.storageKeyAddition,
            notification: request.notification,
            arrayResponse: true)
        if !hasConnection { return }
        
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
     Check to see if there is a network connection - if there is not it will complete the closures available for the request
     - Parameter notification: Notification.Name? = nil
     - Parameter arrayResponse: Bool
     - Parameter closure: Closure<T>
     - Returns: Bool
     */
    private func checkConnection<T: Model>(
        storageKeyAddition: String? = nil,
        notification: Notification.Name? = nil,
        arrayResponse: Bool,
        closure: Closure<T>) -> Bool {
        
        if !NetworkStatusService.hasConnection {
            DispatchQueue.main.async {
                if arrayResponse {
                    let object: [T]? = try? StorageClient.retrieve(storageKey: storageKeyAddition)
                    ClosureService.closures(closure).forEach({
                        $0.blockArr?(object, nil)
                    })
                    
                    if let notification = notification {
                        NotificationCenter.default.post(name: notification, object: object)
                    }
                } else {
                    let object: T? = try? StorageClient.retrieve(storageKey: storageKeyAddition)
                    ClosureService.closures(closure).forEach({
                        $0.blockObj?(object, nil)
                    })
                    
                    if let notification = notification {
                        NotificationCenter.default.post(name: notification, object: object)
                    }
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
    
}
