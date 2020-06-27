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
import RNCryptor

public class SecureService {
    
    private var encryptor: RNCryptor.EncryptorV3?
    private var decryptor: RNCryptor.DecryptorV3?
    
    //==========================================
    // MARK: Singleton
    //==========================================
    
    static let shared = SecureService()
    private init() {
        let encryptionKey = RNCryptor.randomData(ofLength: RNCryptor.FormatV3.keySize)
        let hmacKey = RNCryptor.randomData(ofLength: RNCryptor.FormatV3.keySize)
        
        encryptor = RNCryptor.EncryptorV3(encryptionKey: encryptionKey, hmacKey: hmacKey)
        decryptor = RNCryptor.DecryptorV3(encryptionKey: encryptionKey, hmacKey: hmacKey)
    }
    
    //==========================================
    // MARK: Helpers
    //==========================================
    
    public static func encryptToString(_ data: Data) -> String? {
        let encrypted = shared.encryptor?.encrypt(data: data)
        return encrypted?.base64EncodedString()
    }
    
    public static func encryptToData(_ data: Data) -> Data? {
        return shared.encryptor?.encrypt(data: data)
    }
    
    public static func decrypt(_ string: String) throws -> Data? {
        guard let data = Data(base64Encoded: string) else {
            debugPrint("  [*] WARNING - Encryption has not been used - passing data")
            return string.data(using: .utf8)
        }
        return try shared.decryptor?.decrypt(data: data)
    }
    
    public static func decrypt(_ data: Data) throws -> Data? {
        return try shared.decryptor?.decrypt(data: data)
    }
    
}
