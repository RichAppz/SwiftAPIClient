//
//  DownloadClientExample.swift
//  SwiftAPIClient-Tests
//
//  Created by Rich Mucha on 22/02/2022.
//  Copyright © 2022 RichAppz Limited. All rights reserved.
//

import Foundation

class DownloadClientExample: Service {
    
    // ==========================================
    // MARK: Properties
    // ==========================================
    
    var rootURL = "http://ipv4.download.thinkbroadband.com/"
    var headers: [String: String] = [:]
    let networkQueue = OperationQueue()
    
    // ==========================================
    // MARK: Singleton
    // ==========================================
    
    static let shared = DownloadClientExample()
    
    // ==========================================
    // MARK: Initialization
    // ==========================================
    
    init() { }
    
    // ==========================================
    // MARK: Helpers
    // ==========================================
    
    func post(_ request: Request, completion: OperationResponse? = nil) {
        makeRequest(.post, request: request, completion: completion)
    }
    
    func get(_ request: Request, completion: OperationResponse? = nil) {
        makeRequest(.get, request: request, completion: completion)
    }
    
    func delete(_ request: Request, completion: OperationResponse? = nil) {
        makeRequest(.delete, request: request, completion: completion)
    }
    
    func put(_ request: Request, completion: OperationResponse? = nil) {
        makeRequest(.put, request: request, completion: completion)
    }
    
    func patch(_ request: Request, completion: OperationResponse? = nil) {
        makeRequest(.patch, request: request, completion: completion)
    }
    
}
