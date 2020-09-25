//
//  SecureService.swift
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
import CryptoSwift

public class SecureService {
    
    private var key: String?
    private var iv: String?
    
    //==========================================
    // MARK: Singleton
    //==========================================
    
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
    
    //==========================================
    // MARK: Helpers
    //==========================================
    
    public static func AESEncryptToString(_ data: Data) throws -> String? {
        guard let keyString = shared.key, let ivString = shared.iv, let dataString = data.string else {
            debugPrint("  [*] WARNING - Encryption has not been used - passing string")
            return data.string
        }
        
        let key: [UInt8] = Array(keyString.utf8) as [UInt8]
        let iv: [UInt8] = Array(ivString.utf8) as [UInt8]
        let aes = try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs5)
        let encrypted = try aes.encrypt(Array(dataString.utf8))
        
        return encrypted.toBase64()
    }
    
    public static func AESEncryptToData(_ data: Data) throws -> Data? {
        guard let keyString = shared.key, let ivString = shared.iv, let dataString = data.string else {
            debugPrint("  [*] WARNING - Encryption has not been used - passing string")
            return data
        }
        
        let key: [UInt8] = Array(keyString.utf8) as [UInt8]
        let iv: [UInt8] = Array(ivString.utf8) as [UInt8]
        let aes = try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs5)
        let encrypted = try aes.encrypt(Array(dataString.utf8))
        
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
        guard let keyString = shared.key, let ivString = shared.iv, let dataString = data.string else {
            debugPrint("  [*] WARNING - Encryption has not been used - passing data")
            return data
        }
        
        let key: [UInt8] = Array(keyString.utf8) as [UInt8]
        let iv: [UInt8] = Array(ivString.utf8) as [UInt8]
        let aes = try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs5)
        let decrypted = try aes.decrypt(Array(dataString.utf8))
        
        return Data(decrypted)
    }
    
}
