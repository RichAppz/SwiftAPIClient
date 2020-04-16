//
//  SecureService.swift
//  SimpleAPIClient iOS
//
//  Created by Rich Mucha on 16/04/2019.
//  Copyright © 2019 RichAppz Limited. All rights reserved.
//

import Foundation
import CryptoSwift

public class SecureService {
    
    private var key: String?
    private var iv: String?
    
    //================================================================================
    // MARK: Singleton
    //================================================================================
    
    static let shared = SecureService()
    private init() {
        let dictionary = Bundle.main.infoDictionary
        if let simpleAPIDict = dictionary?["SimpleAPIClient-Keys"] as? [String: Any] {
            key = simpleAPIDict["key"] as? String
            iv = simpleAPIDict["iv"] as? String
        } else {
            debugPrint("  [*] WARNING - If you require secure storage, please ensure that `SimpleAPIClient-Keys` is added to your .plist - see documentation.")
        }
    }
    
    //================================================================================
    // MARK: Helpers
    //================================================================================
    
    public static func AESEncryptToString(_ data: Data) throws -> String? {
        guard let keyString = shared.key, let ivString = shared.iv else {
            debugPrint("  [*] WARNING - Encryption has not been used - passing string")
            return data.string
        }
        
        let key: [UInt8] = Array(keyString.utf8) as [UInt8]
        let iv: [UInt8] = Array(ivString.utf8) as [UInt8]
        let aes = try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs5)
        let encrypted = try aes.encrypt(Array(data.string.utf8))
        
        return encrypted.toBase64()
    }
    
    public static func AESEncryptToData(_ data: Data) throws -> Data? {
        guard let keyString = shared.key, let ivString = shared.iv else {
            debugPrint("  [*] WARNING - Encryption has not been used - passing string")
            return data
        }
        
        let key: [UInt8] = Array(keyString.utf8) as [UInt8]
        let iv: [UInt8] = Array(ivString.utf8) as [UInt8]
        let aes = try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs5)
        let encrypted = try aes.encrypt(Array(data.string.utf8))
        
        return Data(encrypted)
    }
    
    public static func AESDecrypt(_ string: String) throws -> Data? {
        guard let keyString = shared.key, let ivString = shared.iv else {
            debugPrint("  [*] WARNING - Encryption has not been used - passing data")
            return string.data(using: .utf8)
        }
        
        let key: [UInt8] = Array(keyString.utf8) as [UInt8]
        let iv: [UInt8] = Array(ivString.utf8) as [UInt8]
        let aes = try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs5)
        let decrypted = try aes.decrypt(Array(base64: string))
        
        return Data(decrypted)
    }
    
    public static func AESDecrypt(_ data: Data) throws -> Data? {
        guard let keyString = shared.key, let ivString = shared.iv else {
            debugPrint("  [*] WARNING - Encryption has not been used - passing data")
            return data
        }
        
        let key: [UInt8] = Array(keyString.utf8) as [UInt8]
        let iv: [UInt8] = Array(ivString.utf8) as [UInt8]
        let aes = try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs5)
        let decrypted = try aes.decrypt(Array(data.string.utf8))
        
        return Data(decrypted)
    }
    
}
