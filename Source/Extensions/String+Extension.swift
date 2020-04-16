//
//  Extension+String.swift
//  CUVNetworkLayer-iOS
//
//  Created by Rich Mucha on 20/02/2020.
//

import Foundation
import UIKit
import CommonCrypto
import CryptoKit

public extension String {
    
    /**
     Generates a full endpoint with the required parameters
     - Parameter endpoint: String?
     - Parameter endpointParam: String?
     - Returns: String
     */
    static func fullPath(
        endpoint: String? = nil,
        endpointParam: String? = nil) -> String {
        
        if let endpointParam = endpointParam {
            return String(format: endpoint ?? "", endpointParam)
        } else {
            return endpoint ?? ""
        }
    }
    
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
            var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
            _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
                data.withUnsafeBytes { messageBytes -> UInt8 in
                    if
                        let messageBytesBaseAddress = messageBytes.baseAddress,
                        let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                        let messageLength = CC_LONG(data.count)
                        CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                    }
                    return 0
                }
            }
            return digestData.base64EncodedString()
        }
    }
    
}
