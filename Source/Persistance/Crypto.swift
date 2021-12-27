//
//  Crypto.swift
//  SwiftAPIClient
//
//  Created by Rich Mucha on 27/12/2021.
//  Copyright © 2021 RichAppz Limited. All rights reserved.
//

import Foundation
import CommonCrypto

public enum CryptoError: Error {
    case KeyError((String, Int))
    case IVError((String, Int))
    case CryptorError((String, Int))
}

public class Crypto {

    /**
     New AES128 key generation
     */
    public class var newKey: String {
        return UUID().uuidString
            .replacingOccurrences(of: "-", with: "")
            .substring(to: 16)
    }
    
    // The iv is prefixed to the encrypted data
    internal class func aesCBCEncrypt(
        data: Data,
        keyData: Data) throws -> Data {
            let keyLength = keyData.count
            let validKeyLengths = [kCCKeySizeAES128, kCCKeySizeAES192, kCCKeySizeAES256]
            if !validKeyLengths.contains(keyLength) {
                throw CryptoError.KeyError(
                    ("Invalid key length", keyLength)
                )
            }

            let ivSize = kCCBlockSizeAES128
            let cryptLength = size_t(ivSize + data.count + kCCBlockSizeAES128)
            var cryptData = Data(count: cryptLength)

            let status = cryptData.withUnsafeMutableBytes { ivBytes in
                SecRandomCopyBytes(kSecRandomDefault, kCCBlockSizeAES128, ivBytes)
            }
            
            if status != 0 {
                throw CryptoError.IVError(
                    ("IV generation failed", Int(status))
                )
            }

            var numBytesEncrypted: size_t = 0
            let options = CCOptions(kCCOptionPKCS7Padding)
            
            let cryptStatus = cryptData.withUnsafeMutableBytes { cryptBytes in
                data.withUnsafeBytes { dataBytes in
                    keyData.withUnsafeBytes {keyBytes in
                        CCCrypt(CCOperation(kCCEncrypt),
                                CCAlgorithm(kCCAlgorithmAES),
                                options,
                                keyBytes, keyLength,
                                cryptBytes,
                                dataBytes, data.count,
                                cryptBytes+kCCBlockSizeAES128, cryptLength,
                                &numBytesEncrypted)
                    }
                }
            }

            if UInt32(cryptStatus) == UInt32(kCCSuccess) {
                cryptData.count = numBytesEncrypted + ivSize
            } else {
                throw CryptoError.CryptorError(
                    ("Encryption failed", Int(cryptStatus))
                )
            }

            return cryptData
        }

    // The iv is prefixed to the encrypted data
    internal class func aesCBCDecrypt(
        data: Data,
        keyData: Data) throws -> Data? {
            let keyLength = keyData.count
            let validKeyLengths = [kCCKeySizeAES128, kCCKeySizeAES192, kCCKeySizeAES256]
            
            if !validKeyLengths.contains(keyLength) {
                throw CryptoError.KeyError(("Invalid key length", keyLength))
            }

            let ivSize = kCCBlockSizeAES128
            let clearLength = size_t(data.count - ivSize)
            var clearData = Data(count: clearLength)

            var numBytesDecrypted: size_t = 0
            let options = CCOptions(kCCOptionPKCS7Padding)

            let cryptStatus = clearData.withUnsafeMutableBytes { cryptBytes in
                data.withUnsafeBytes { dataBytes in
                    keyData.withUnsafeBytes { keyBytes in
                        CCCrypt(CCOperation(kCCDecrypt),
                                CCAlgorithm(kCCAlgorithmAES128),
                                options,
                                keyBytes, keyLength,
                                dataBytes,
                                dataBytes+kCCBlockSizeAES128, clearLength,
                                cryptBytes, clearLength,
                                &numBytesDecrypted)
                    }
                }
            }

            if UInt32(cryptStatus) == UInt32(kCCSuccess) {
                clearData.count = numBytesDecrypted
            } else {
                throw CryptoError.CryptorError(
                    ("Decryption failed", Int(cryptStatus))
                )
            }
            
            return clearData
        }
    
}

public extension Data {
    
    func cryptoEncodeToString(
        key: String) throws -> String? {
            return try cryptoEncodeToData(key: key)?.base64EncodedString()
        }
    
    func cryptoEncodeToData(
        key: String) throws -> Data? {
            guard let keyData = key.data(using: String.Encoding.utf8) else {
                throw CryptoError.CryptorError(
                    ("Key data failed", 0)
                )
            }
            
            return try Crypto.aesCBCEncrypt(
                data: self,
                keyData: keyData
            )
        }
    
    func cryptoDecode(
        key: String) throws -> Data? {
            guard let keyData = key.data(using: String.Encoding.utf8) else {
                throw CryptoError.CryptorError(
                    ("Key data failed", 0)
                )
            }
            
            return try Crypto.aesCBCDecrypt(
                data: self,
                keyData: keyData
            )
        }
    
}

public extension String {
    
    func cryptoDecode(
        key: String) throws -> Data? {
            guard
                let data = Data(base64Encoded: self),
                let keyData = key.data(using: String.Encoding.utf8) else {
                throw CryptoError.CryptorError(
                    ("Key data failed", 0)
                )
            }
            
            return try Crypto.aesCBCDecrypt(
                data: data,
                keyData: keyData
            )
        }
    
}

internal extension String {
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
    
}
