//
//  ClientExample.swift
//  APIClient
//
//  Created by Rich Mucha on 11/12/2017.
//  Copyright © 2019 RichAppz Limited. All rights reserved.
//

import Foundation

class ClientExample: Service {
    
    // ==========================================
    // MARK: Properties
    // ==========================================
    
    var rootURL = "http://www.omdbapi.com/?i=tt3896198&apikey=8bac532c"
    var headers: [String: String] = [:]
    let networkQueue = OperationQueue()
    
    // ==========================================
    // MARK: Singleton
    // ==========================================
    
    static let shared = ClientExample()
    
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
