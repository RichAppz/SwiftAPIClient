//
//  NetworkResponseTests.swift
//  SimpleAPIClient iOS Tests
//
//  Created by Rich Mucha on 20/03/2019.
//  Copyright © 2019 RichAppz Limited. All rights reserved.
//

import XCTest

class NetworkResponseTests: XCTestCase {
    
    //================================================================================
    // MARK: Setup
    //================================================================================
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    //================================================================================
    // MARK: Tests
    //================================================================================
    
    func testFetchMoviesExample() {
        let expectation = self.expectation(description: "fetching movies from omdb")
        
        let query = "Hero"
        ClientExample.shared.fetchMovieWith(query: query) { (movie, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(movie)
            XCTAssert(movie?.title == query)
            
            do {
                let sMovie: Movie? = try StorageClient.retrieve()
                XCTAssert(movie?.title == sMovie?.title)
                expectation.fulfill()
            } catch {
                debugPrint(error.localizedDescription)
                XCTFail("Data retrieval failed")
            }
        }
        
        waitForExpectations(timeout: 30) { error in
            print(error as Any)
        }
    }
    
}
