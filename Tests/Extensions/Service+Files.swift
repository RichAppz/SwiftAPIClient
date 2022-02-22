//
//  Service+Files.swift
//  SwiftAPIClient-Tests
//
//  Created by Rich Mucha on 22/02/2022.
//  Copyright © 2022 RichAppz Limited. All rights reserved.
//

import Foundation

extension Service {
    
    public func stdFileDownload(
        fileName: String,
        completion: @escaping (URL?, Error?) -> Void) {
            get(
                Request(
                    endpoint: fileName,
                    operationType: .fileDownload)
                ) { (response) in
                    DispatchQueue.main.async {
                        completion(response.fileStoreUrl, response.error)
                    }
            }
        }
    
}
