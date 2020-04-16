//
//  StorageClient.swift
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

public enum StorageType {
    case userDefaults, fileManager, none
}

public enum StorageClientError: Error {
    case fileManagerFailure
    case noDataAvailable
}

internal let kUserDefaultExtension = ".client.store"

public class StorageClient {
    
    //==========================================
    // MARK: Data
    //==========================================
    
    var data: [String: String] = [:] {
        didSet { StorageClient.save() }
    }
    
    //==========================================
    // MARK: Singleton
    //==========================================
    
    static let shared = StorageClient()
    
    private init() {
        #if os(iOS) || os(macOS) || os(tvOS)
        do {
            data = try FileManager.fetchPlist(named: kPlistFilename)
        } catch {
            debugPrint(error.localizedDescription)
        }
        #endif
    }
    
    //==========================================
    // MARK: Mapping Functions
    //==========================================
    
    /**
     Maps response data from a network request directly into a Model Array using decodable, during this action the method will also hand  the data persistance.
     - Parameter object: Data?
     - Parameter storageKey: <Optional>String - this is only required if a non default location needs to be used
     - Parameter storageType: StorageType - a choice of where the persistance is to be store - StorageType.userDefaults  StorageType.fileManager / StorageType.none
     - Returns: Array<Model>
     - Throws: DecodingError
     */
    public static func map<T: Model>(object: Data?, storageKey: String? = nil, storageType: StorageType = .fileManager) throws -> [T]? {
        guard let object = object else { return nil }
        try store(object, storageIdentifier: T.storageIdentifier, storageKey: storageKey, storageType: storageType)
        
        return try CoderModule.decoder.decode([T].self, from: object)
    }
    
    /**
     Maps response data from a network request directly into a Model using decodable, during this action the method will also handle the da   persistance.
     - Parameter object: Data?
     - Parameter storageKey: <Optional>String - this is only required if a non default location needs to be used
     - Parameter storageType:  StorageType - a choice of where the persistance is to be store - StorageType.userDefaults      StorageType.fileManager / StorageType.none
     - Returns: Array<Model>
     - Throws: DecodingError
     */
    public static func map<T: Model>(object: Data?, storageKey: String? = nil, storageType: StorageType = .fileManager) throws -> T? {
        guard let object = object else { return nil }
        try store(object, storageIdentifier: T.storageIdentifier, storageKey: storageKey, storageType: storageType)
        
        return try CoderModule.decoder.decode(T.self, from: object)
    }
    
    /**
     Clears all the data that has been saved by the client from the FileManger, UserDefaults and the Singleton itself
     - Throws: FileManagerError
     */
    public static func clear() throws {
        #if os(iOS) || os(macOS) || os(tvOS)
        try FileManager.removePlist(named: kPlistFilename)
        #endif
        
        let storageItems = UserDefaults.standard.dictionaryRepresentation().filter({ $0.key.contains(kUserDefaultExtension) })
        storageItems.forEach({ UserDefaults.standard.removeObject(forKey: $0.key) })
        shared.data = [:]
    }
    
    //==========================================
    // MARK: Retrieve Functions
    //==========================================
    
    #if os(iOS) || os(macOS) || os(tvOS)
    /**
     Model array retrieval from any type of storage if available
     - Parameter storageKey: <Optional>String - this is only required if a non default location needs to be used
     - Returns: Array<Model>
     - Throws: DecodingError
     */
    public static func retrieve<T: Model>(storageKey: String? = nil) throws -> [T]? {
        let additional = storageKey?.isEmpty ?? true ? "" : String(format: ".%@", storageKey!)
        let storageId = String(format: "%@%@%@", T.storageIdentifier, additional, kUserDefaultExtension)
        
        if
            let dataString = UserDefaults.standard.string(forKey: storageId),
            let data = try SecureService.AESDecrypt(dataString) {
            return try? CoderModule.decoder.decode([T].self, from: data)
        }
        
        if
            let dataString = shared.data[storageId],
            let data = try SecureService.AESDecrypt(dataString) {
            return try? CoderModule.decoder.decode([T].self, from: data)
        }
        
        throw StorageClientError.noDataAvailable
    }
    
    /**
     Model retrieval from any type of storage if available
     - Parameter storageKey: <Optional>String - this is only required if a non default location needs to be used
     - Returns: Model
     - Throws: DecodingError
     */
    public static func retrieve<T: Model>(storageKey: String? = nil) throws -> T? {
        let additional = storageKey?.isEmpty ?? true ? "" : String(format: ".%@", storageKey!)
        let storageId = String(format: "%@%@%@", T.storageIdentifier, additional, kUserDefaultExtension)
        
        if
            let dataString = UserDefaults.standard.string(forKey: storageId),
            let data = try SecureService.AESDecrypt(dataString) {
            return try? CoderModule.decoder.decode(T.self, from: data)
        }
        
        if
            let directory = shared.data[storageId],
            let data = try SecureService.AESDecrypt(directory) {
            return try? CoderModule.decoder.decode(T.self, from: data)
        }
        
        throw StorageClientError.noDataAvailable
    }
    #endif
    
    //==========================================
    // MARK: Clear Functions
    //==========================================
    
    public static func remove<T: Model>(objectType: T?, storageKey: String? = nil) throws {
        let additional = storageKey?.isEmpty ?? true ? "" : String(format: ".%@", storageKey!)
        let storageId = String(format: "%@%@%@", T.storageIdentifier, additional, kUserDefaultExtension)
        
        UserDefaults.standard.removeObject(forKey: storageId)
        
    }
    
    public static func remove<T: Model>(objectType: [T]?, storageKey: String? = nil) throws {
        let additional = storageKey?.isEmpty ?? true ? "" : String(format: ".%@", storageKey!)
        let storageId = String(format: "%@%@%@", T.storageIdentifier, additional, kUserDefaultExtension)
        
        UserDefaults.standard.removeObject(forKey: storageId)
        
    }
    
    //==========================================
    // MARK: Helpers
    //==========================================
    
    internal static func store(
        _ data: Data?,
        storageIdentifier: String,
        storageKey: String? = nil,
        storageType: StorageType) throws {
        guard let data = data else { return }
        
        #if os(iOS) || os(macOS) || os(tvOS)
        let additional = storageKey?.isEmpty ?? true ? "" : String(format: ".%@", storageKey!)
        let storageId = String(format: "%@%@%@", storageIdentifier, additional, kUserDefaultExtension)
        
        switch storageType {
        case .fileManager:
            try fileManagerStore(data, storageIdentifier: storageId)
        case .userDefaults:
            try userDefaultStore(data, storageIdentifier: storageId)
        case .none:
            break
        }
        #endif
    }
    
    private static func userDefaultStore(
        _ data: Data,
        storageIdentifier: String) throws {
        
        let secureData = try SecureService.AESEncryptToString(data)
        DispatchQueue.main.async {
            UserDefaults.standard.set(secureData, forKey: storageIdentifier)
        }
    }
    
    private static func fileManagerStore(
        _ data: Data,
        storageIdentifier: String) throws {
        
        let secureData = try SecureService.AESEncryptToString(data)
        shared.data[storageIdentifier] = secureData
    }
    
    private static func save() {
        #if os(iOS) || os(macOS) || os(tvOS)
        do {
            try FileManager.savePlist(named: kPlistFilename, dict: shared.data)
        } catch {
            debugPrint(error.localizedDescription)
        }
        #endif
    }
    
}

public extension Array where Element: Model {
    
    /**
     This method will persist the Model Array passed into the memory
     - Parameter storageKey: <Optional>String - this is only required if a non default location needs to be used
     - Parameter storageType:  StorageType - a choice of where the persistance is to be store - StorageType.userDefaults      StorageType.fileManager / StorageType.none
     - Returns: status Bool
     - Throws: DecodingError
     */
    func save(storageKey: String? = nil, storageType: StorageType = .userDefaults) throws {
        guard let firstObj = first else { return }
        
        let data = try CoderModule.encoder.encode(self)
        try StorageClient.store(
            data,
            storageIdentifier: type(of: firstObj).storageIdentifier,
            storageKey: storageKey,
            storageType: storageType
        )
    }
    
}

public extension Optional where Wrapped: Model {
    
    /**
     This method will persist the Model Array passed into the memory
     - Parameter storageKey: <Optional>String - this is only required if a non default location needs to be used
     - Parameter storageType:  StorageType - a choice of where the persistance is to be store - StorageType.userDefaults      StorageType.fileManager / StorageType.none
     - Returns: status Bool
     - Throws: DecodingError
     */
    func save(storageKey: String? = nil, storageType: StorageType = .userDefaults) throws {
        guard let obj = self else { return }
        
        let data = try CoderModule.encoder.encode(self)
        try StorageClient.store(
            data,
            storageIdentifier: type(of: obj).storageIdentifier,
            storageKey: storageKey, storageType: storageType)
    }
    
}
