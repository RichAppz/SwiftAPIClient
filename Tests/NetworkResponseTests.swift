//
//  NetworkResponseTests.swift
//  SwiftAPIClient iOS Tests
//
//  Created by Rich Mucha on 20/03/2019.
//  Copyright © 2019 RichAppz Limited. All rights reserved.
//

import XCTest

class NetworkResponseTests: XCTestCase {
    
    // ==========================================
    // MARK: Setup
    // ==========================================
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // ==========================================
    // MARK: Tests
    // ==========================================
    
    func testFetchMoviesExample() {
        let expectation = self.expectation(description: "fetching movies from omdb")
        
        let query = "Hero"
        ClientExample.shared.fetchMovieWith(query: query) { (movie, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(movie)
            XCTAssert(movie?.title == query)
            
            do {
                let completionBlock: ((Movie?) -> Void) = {sMovie in
                    XCTAssert(movie?.title == sMovie?.title)
                    expectation.fulfill()
                }
                
                try StorageClient.retrieve(completion: completionBlock)
            } catch {
                debugPrint(error.localizedDescription)
                XCTFail("Data retrieval failed")
            }
        }
        
        waitForExpectations(timeout: 10) { error in
            print(error as Any)
        }
    }
    
    func testFetchMoviesStandardExample() {
        let expectation = self.expectation(description: "fetching movies from omdb")
        
        let query = "Hero"
        ClientExample.shared.stdRequestFetchMovieWith(query: query) { (movie, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(movie)
            XCTAssert(movie?.title == query)
            
            do {
                let completionBlock: ((Movie?) -> Void) = {sMovie in
                    XCTAssert(movie?.title == sMovie?.title)
                    expectation.fulfill()
                }
                
                try StorageClient.retrieve(completion: completionBlock)
            } catch {
                debugPrint(error.localizedDescription)
                XCTFail("Data retrieval failed")
            }
        }
        
        waitForExpectations(timeout: 10) { error in
            print(error as Any)
        }
    }
    
    func testFileDownload() {
        let expectation = self.expectation(description: "fetching file from speedtest")
        
        let filename = "5MB.zip"
        DownloadClientExample.shared.stdFileDownload(
            fileName: filename) { url, error in
                XCTAssertNil(error)
                XCTAssertNotNil(url)
                XCTAssert(url?.absoluteString.contains(filename) ?? false)
                
                XCTAssert(FileManager.default.fileExists(atPath: url!.path))
                XCTAssert(FileManager.default.isReadableFile(atPath: url!.path))
                if let value = try? FileManager.default.attributesOfItem(atPath: url!.path)[FileAttributeKey.size] as? Int {
                    XCTAssert(value > 5000000)
                } else {
                    XCTFail("file size missing")
                }
                
                expectation.fulfill()
            }
        
        waitForExpectations(timeout: 30) { error in
            print(error as Any)
        }
    }
    
}
