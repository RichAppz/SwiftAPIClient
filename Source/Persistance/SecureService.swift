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

public class SecureService {
    
    private var key = Crypto.newKey
    
    static var useEncryption = false
    
    // ==========================================
    // MARK: Singleton
    // ==========================================
    
    static let shared = SecureService()
    
    // ==========================================
    // MARK: Helpers
    // ==========================================
    
    public static func encryptToString(_ data: Data) throws -> String? {
        if useEncryption {
            return try? data.cryptoEncodeToString(key: shared.key)
        } else {
            return String(data: data, encoding: .utf8)
        }
    }
    
    public static func AESEncryptToData(_ data: Data) throws -> Data? {
        if useEncryption {
            return try? data.cryptoEncodeToData(key: shared.key)
        } else {
            return data
        }
    }
    
    public static func AESDecrypt(_ string: String) throws -> Data? {
        if useEncryption {
            return try? string.cryptoDecode(key: shared.key)
        } else {
            return string.data(using: .utf8)
        }
    }
    
    public static func AESDecrypt(_ data: Data) throws -> Data? {
        if useEncryption {
            return try? data.cryptoDecode(key: shared.key)
        } else {
            return data
        }
    }
    
}
