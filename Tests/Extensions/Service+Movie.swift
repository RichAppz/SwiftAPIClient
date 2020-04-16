//
//  Service+Movie.swift
//  SwiftAPIClient iOS Tests
//
//  Created by Rich Mucha on 20/03/2019.
//  Copyright © 2019 RichAppz Limited. All rights reserved.
//

import Foundation

extension Service {
    
    public func fetchMovieWith(query: String, completion: @escaping ((Movie?, Error?) -> Void)) {
        get(Request(
            parameters: ["t": query])
        ) { (response) in
            let movie: Movie? = try? StorageClient.map(object: response.data)
            DispatchQueue.main.async {
                completion(movie, response.error)
            }
        }
    }
    
    public func stdRequestFetchMovieWith(query: String, completion: @escaping ((Movie?, Error?) -> Void)) {
        stdGetRequest(
            RequestModel(
                params: ["t": query],
                storageType: .fileManager),
            completion: completion
        )
    }
    
}
