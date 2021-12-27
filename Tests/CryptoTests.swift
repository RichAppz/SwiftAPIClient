//
//  CryptoTests.swift
//  SwiftAPIClient-Tests
//
//  Created by Rich Mucha on 27/12/2021.
//  Copyright © 2021 RichAppz Limited. All rights reserved.
//

import XCTest

class CryptoTests: XCTestCase {

    // ================================================================================
    // MARK: Properties
    // ================================================================================
    
    let key = Crypto.newKey
    let testableString = "This string should be intact when decrypted"

    // ================================================================================
    // MARK: Setup
    // ================================================================================
    
    override func setUp() {
        super.setUp()
    }
    
    // ================================================================================
    // MARK: Tests
    // ================================================================================
    
    func testEncryption() throws {
        guard let string = testableString.data(using: String.Encoding.utf8) else {
            throw CryptoError.CryptorError(
                ("Key data failed", 0)
            )
        }
        
        do {
            guard let encryptedString = try string.cryptoEncodeToString(key: key) else {
                XCTFail("Data encryption failed")
                return
            }
            
            XCTAssertTrue(!encryptedString.isEmpty)
            
            guard
                let returned = try encryptedString.cryptoDecode(key: key) else {
                XCTFail("Data decryption failed")
                return
            }
            XCTAssertTrue(!returned.isEmpty)
            XCTAssertTrue(returned.string == testableString)
        } catch {
            debugPrint(error)
            XCTFail("Data encryption failed")
        }
    }

}
