//
//  Extension+String.swift
//  CUVNetworkLayer-iOS
//
//  Created by Rich Mucha on 20/02/2020.
//

import Foundation
import CommonCrypto
import CryptoKit

public extension String {
    
    /**
     Generates a full endpoint with the required parameters
     - Parameter endpoint: String?
     - Parameter endpointParams: [Any]?
     - Returns: String
     */
    static func fullPath(
        endpoint: String? = nil,
        endpointParams: [Any]? = nil) -> String {
        
        if let array = endpointParams?.compactMap({ $0 as? CVarArg }) {
            return String(format: endpoint ?? "", arguments: array)
        } else {
            return endpoint ?? ""
        }
    }
    
    var asURL: URL? {
        return URL(string: self)
    }
    
    #if os(iOS)
    /**
    - Returns: String - SHA256 hash of the string provided
    */
    var ccSHA256: String? {
        guard let data = data(using: .utf8) else { return nil }
        
        if #available(iOS 13.0, *) {
            let hashed = SHA256.hash(data: data)
            let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
            return hashString
        } else {
            return data.preLatestHash
        }
    }
    #endif
    
    #if os(watchOS)
    /**
    - Returns: String - SHA256 hash of the string provided
    */
    var ccSHA256: String? {
        guard let data = data(using: .utf8) else { return nil }
        
        if #available(watchOSApplicationExtension 6.0, *) {
            let hashed = SHA256.hash(data: data)
            let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
            return hashString
        } else {
            return data.preLatestHash
        }
    }
    #endif
    
    #if os(tvOS)
    /**
    - Returns: String - SHA256 hash of the string provided
    */
    var ccSHA256: String? {
        guard let data = data(using: .utf8) else { return nil }
        
        if #available(tvOS 13.0, *) {
            let hashed = SHA256.hash(data: data)
            let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
            return hashString
        } else {
            return data.preLatestHash
        }
    }
    #endif
    
    #if os(macOS)
    /**
     - Returns: String - SHA256 hash of the string provided
     */
    var ccSHA256: String? {
        guard let data = data(using: .utf8) else { return nil }
        
        if #available(OSX 10.15, *) {
            let hashed = SHA256.hash(data: data)
            let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
            return hashString
        } else {
            return data.preLatestHash
        }
    }
    #endif
    
}

extension Data {
    
    var preLatestHash: String? {
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            self.withUnsafeBytes { messageBytes -> UInt8 in
                if
                    let messageBytesBaseAddress = messageBytes.baseAddress,
                    let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(self.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData.base64EncodedString()
    }
    
}
