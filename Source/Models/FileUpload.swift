//
//  FileUpload.swift
//  SwiftAPIClient
//
//  Created by Rich Mucha on 22/02/2022.
//  Copyright © 2022 RichAppz Limited. All rights reserved.
//

import Foundation

public struct FileUpload {
    
    /// If you are converting images you can use `jpegData(compressionQuality: 0.5)`
    public let data: Data
    /// This is the parameter expected by your server
    public let paramName: String
    /// Needs to contain the file extension also eg `filename.png`
    public let fullFileName: String
    /// Standard mimeType string that is expected by HTTP Requests
    public let mimeType: String
    
    public init(
        data: Data,
        paramName: String,
        fullFileName: String,
        mimeType: String) {
            self.data = data
            self.paramName = paramName
            self.fullFileName = fullFileName
            self.mimeType = mimeType
        }
    
}
