//
//  FileManager+Extension.swift
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

public enum FileManagerError: Error {
    case documentDirectoryMissing
    case plistNotSaved
    case deletionFailed
}

internal let plistFilename = "SimpleAPIClient"

internal class FileManagerQueue {
    
    // ==========================================
    // MARK: Singleton
    // ==========================================
    
    static let queue = DispatchQueue(
        label: "com.swiftapiclient.storage.queue",
        attributes: .concurrent
    )
    
}

#if os(iOS) || os(macOS) || os(tvOS)
internal extension FileManager {
    
    /**
     Fetches JSON file from local storage
     - Parameter name:  String - name of JSON file that is required
     - Returns: Dictionary<String, String>
     */
    static func fetchPlist(named: String) throws -> [String: String] {
        guard let directory = self.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileManagerError.documentDirectoryMissing
        }
        
        let directoryPath = directory.appendingPathComponent(plistFilename)
        let path = directoryPath.appendingPathComponent(named, isDirectory: false).appendingPathExtension("plist")
        
        if
            let data = self.default.contents(atPath: path.path),
            let dict = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String: String] {
            return dict
        } else {
            /// The file does not exist so we will create one.
            let dictionary: [String: String] = ["version": "1.0.0"]
            let data = try NSKeyedArchiver.archivedData(withRootObject: dictionary, requiringSecureCoding: true)
            
            try self.default.createDirectory(atPath: directoryPath.path, withIntermediateDirectories: true, attributes: nil)
            if !self.default.createFile(atPath: path.path, contents: data, attributes: nil) {
                throw FileManagerError.plistNotSaved
            }
            return dictionary
        }
    }
    
    /**
     Saves JSON to local storage
     - Parameter name:  String - name of JSON file that is required
     - Parameter dict:      Dictionary<String, String> - json that is required to be saved
     - Throws: FileManagerError.documentDirectoryMissing, FileManagerError.plistNotSaved
     */
    static func savePlist(named: String, dict: [String: String]) throws {
        guard let directory = self.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileManagerError.documentDirectoryMissing
        }
        
        try FileManagerQueue.queue.sync {
            let directoryPath = directory.appendingPathComponent(plistFilename)
            let path = directoryPath.appendingPathComponent(named).appendingPathExtension("plist")
            let data = try NSKeyedArchiver.archivedData(withRootObject: dict, requiringSecureCoding: true)
            try data.write(to: path, options: .atomic)
        }
    }
    
    /**
     Removes JSON from local storage
     - Parameter name:  String - name of JSON file that is required
     - Parameter dict:      Dictionary<String, String> - json that is required to be saved
     - Throws: FileManagerError.documentDirectoryMissing, FileManagerError.deletionFailed
     */
    static func removePlist(named: String) throws {
        guard let directory = self.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileManagerError.documentDirectoryMissing
        }
        
        try FileManagerQueue.queue.sync {
            let directoryPath = directory.appendingPathComponent(plistFilename)
            let path = directoryPath.appendingPathComponent(named).appendingPathExtension("plist")
            try self.default.removeItem(at: path)
        }
    }
    
}
#endif
