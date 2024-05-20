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

internal let kUserDefaultExtension = "client.store."

public class StorageClient {
    
    // ==========================================
    // MARK: Data
    // ==========================================
    
    var data: [String: String] = [:] {
        didSet {
            DispatchQueue.global(qos: .background).async {
                StorageClient.save()
            }
        }
    }
    
    // ==========================================
    // MARK: Singleton
    // ==========================================
    
    private static let queue = DispatchQueue(
        label: "com.swiftapiclient.storage.queue",
        attributes: .concurrent
    )
    
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
    
    // ==========================================
    // MARK: Mapping Functions
    // ==========================================
    
    /**
     Setup to enable/disable encryption on the service
     - Parameter useEncryption: Bool
     */
    public static func setup(useEncryption: Bool = false) {
        SecureService.useEncryption = useEncryption
    }
    
    /**
     Maps response data from a network request directly into a Model Array using decodable, during this action the method will also hand  the data persistance.
     - Parameter object: Data
     - Parameter storageKey: <Optional>String - this is only required if a non default location needs to be used
     - Parameter storageType: StorageType - a choice of where the persistance is to be store - StorageType.userDefaults  StorageType.fileManager / StorageType.none
     - Returns: Array<Model>
     - Throws: DecodingError
     */
    public static func map<T: Model>(object: Data?, storageKey: String? = nil, storageType: StorageType = .fileManager) throws -> [T]? {
        guard let object = object else { return nil }
        let models: [T]? = try CoderModule.decoder.decode([T].self, from: object)
        try store(object, storageIdentifier: T.storageIdentifier, storageKey: storageKey, storageType: storageType)
        
        return models
    }
    
    /**
     Maps response data from a network request directly into a Model using decodable, during this action the method will also handle the da   persistance.
     - Parameter object: Data
     - Parameter storageKey: <Optional>String - this is only required if a non default location needs to be used
     - Parameter storageType: StorageType - a choice of where the persistance is to be store - StorageType.userDefaults      StorageType.fileManager / StorageType.none
     - Returns: Array<Model>
     - Throws: DecodingError
     */
    public static func map<T: Model>(object: Data?, storageKey: String? = nil, storageType: StorageType = .fileManager) throws -> T? {
        guard let object = object else { return nil }
        let model: T? = try CoderModule.decoder.decode(T.self, from: object)
        try store(object, storageIdentifier: T.storageIdentifier, storageKey: storageKey, storageType: storageType)
        
        return model
    }
    
    /**
     Removes `Model` from storage
     - Parameter model: Model.Type
     */
    public static func remove(model: Model.Type, completion: (() -> Void)? = nil) {
        #if os(iOS) || os(macOS) || os(tvOS)
        let storageId = String(format: "%@%@", kUserDefaultExtension, model.storageIdentifier)
        
        let items = UserDefaults.standard.dictionaryRepresentation().filter({ $0.key.contains(storageId) })
        items.forEach {
            UserDefaults.standard.set(nil, forKey: $0.key)
            shared.data[$0.key] = nil
        }
        
        queue.sync {
            let storedItems = shared.data.keys.filter({ $0.contains(storageId) })
            storedItems.forEach {
                shared.data[$0] = nil
            }
            
            completion?()
        }
        #endif
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
    
    // ==========================================
    // MARK: Retrieve Functions
    // ==========================================
    
    #if os(iOS) || os(macOS) || os(tvOS)
    /**
     Model array retrieval from any type of storage if available
     
     - Parameter storageKey: <Optional>String - this is only required if a non default location needs to be used
     - Returns: Array<Model>
     - Throws: DecodingError
     */
    public static func retrieve<T: Model>(storageKey: String? = nil, completion: (([T]?) -> Void)) throws {
        let additional = storageKey?.isEmpty ?? true ? "" : String(format: ".%@", storageKey!)
        let storageId = String(format: "%@%@%@", kUserDefaultExtension, T.storageIdentifier, additional)
        
        if
            let dataString = UserDefaults.standard.string(forKey: storageId),
            let data = try SecureService.AESDecrypt(dataString) {
            completion(try CoderModule.decoder.decode([T].self, from: data))
            return
        }
        
        try queue.sync {
            if
                let dataString = shared.data[storageId],
                let data = try SecureService.AESDecrypt(dataString) {
                completion(try CoderModule.decoder.decode([T].self, from: data))
                return
            }
            
            throw StorageClientError.noDataAvailable
        }
        
    }
    
    /**
     Model retrieval from any type of storage if available
     
     - Parameter storageKey: <Optional>String - this is only required if a non default location needs to be used
     - Returns: Model
     - Throws: DecodingError
     */
    public static func retrieve<T: Model>(storageKey: String? = nil, completion: ((T?) -> Void)) throws {
        let additional = storageKey?.isEmpty ?? true ? "" : String(format: ".%@", storageKey!)
        let storageId = String(format: "%@%@%@", kUserDefaultExtension, T.storageIdentifier, additional)
        
        if
            let directory = shared.data[storageId],
            let data = try SecureService.AESDecrypt(directory) {
            completion(try CoderModule.decoder.decode(T.self, from: data))
            return
        }
        
        try queue.sync {
            if
                let dataString = UserDefaults.standard.string(forKey: storageId),
                let data = try SecureService.AESDecrypt(dataString) {
                completion(try CoderModule.decoder.decode(T.self, from: data))
                return
            }
            
            throw StorageClientError.noDataAvailable
        }
    }
    #endif
    
    // ==========================================
    // MARK: Clear Functions
    // ==========================================
    
    public static func remove<T: Model>(objectType: T?, storageKey: String? = nil) throws {
        let additional = storageKey?.isEmpty ?? true ? "" : String(format: ".%@", storageKey!)
        let storageId = String(format: "%@%@%@", kUserDefaultExtension, T.storageIdentifier, additional)
        
        UserDefaults.standard.removeObject(forKey: storageId)
    }
    
    public static func remove<T: Model>(objectType: [T]?, storageKey: String? = nil) throws {
        let additional = storageKey?.isEmpty ?? true ? "" : String(format: ".%@", storageKey!)
        let storageId = String(format: "%@%@%@", kUserDefaultExtension, T.storageIdentifier, additional)
        
        UserDefaults.standard.removeObject(forKey: storageId)
    }
    
    // ==========================================
    // MARK: Helpers
    // ==========================================
    
    internal static func store(
        _ data: Data?,
        storageIdentifier: String,
        storageKey: String? = nil,
        storageType: StorageType) throws {
        guard let data = data else { return }
        
        #if os(iOS) || os(macOS) || os(tvOS)
        let additional = storageKey?.isEmpty ?? true ? "" : String(format: ".%@", storageKey!)
        let storageId = String(format: "%@%@%@", kUserDefaultExtension, storageIdentifier, additional)
        
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
        
        let secureData = try SecureService.encryptToString(data)
        UserDefaults.standard.set(secureData, forKey: storageIdentifier)
    }
    
    private static func fileManagerStore(
        _ data: Data,
        storageIdentifier: String) throws {
        
        let secureData = try SecureService.encryptToString(data)
        queue.sync {
            shared.data[storageIdentifier] = secureData
        }
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
    func save(storageKey: String? = nil, storageType: StorageType = .fileManager) throws {
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
    func save(storageKey: String? = nil, storageType: StorageType = .fileManager) throws {
        guard let obj = self else { return }
        
        let data = try CoderModule.encoder.encode(self)
        try StorageClient.store(
            data,
            storageIdentifier: type(of: obj).storageIdentifier,
            storageKey: storageKey, storageType: storageType)
    }
    
}

public extension Model {
    
    /**
     This method will persist the Model Array passed into the memory
     - Parameter storageKey: <Optional>String - this is only required if a non default location needs to be used
     - Parameter storageType:  StorageType - a choice of where the persistance is to be store - StorageType.userDefaults      StorageType.fileManager / StorageType.none
     - Returns: status Bool
     - Throws: DecodingError
     */
    func save(storageKey: String? = nil, storageType: StorageType = .fileManager) throws {
        let data = try CoderModule.encoder.encode(self)
        try StorageClient.store(
            data,
            storageIdentifier: type(of: self).storageIdentifier,
            storageKey: storageKey,
            storageType: storageType
        )
    }
    
}
