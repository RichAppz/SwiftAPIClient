//
//  StorageTests.swift
//  SwiftAPIClient iOS Tests
//
//  Created by Rich Mucha on 20/03/2019.
//  Copyright © 2019 RichAppz Limited. All rights reserved.
//

import XCTest

// swiftlint:disable line_length
class StorageTests: XCTestCase {

    //================================================================================
    // MARK: Properties
    //================================================================================
    
    let movieJson: String = "{\"Title\":\"The Green Mile\",\"Year\":\"1999\",\"Rated\":\"R\",\"Genre\":\"Crime, Drama, Fantasy, Mystery\"}"
    let movieJsonArray: String = "[ {\"Title\":\"The Green Mile\",\"Year\":\"1999\",\"Rated\":\"R\",\"Genre\":\"Crime, Drama, Fantasy, Mystery\"},{\"Title\":\"Fast and Furious\",\"Year\": \"1939\",\"Rated\":\"PASSED\",\"Genre\": \"Comedy, Crime, Musical, Mystery, Director\"}]"
    
    //================================================================================
    // MARK: Setup
    //================================================================================
    
    override func setUp() {
        super.setUp()
    }

    //================================================================================
    // MARK: Tests
    //================================================================================
    
    func testMovieExample() {
        let movie: Movie? = try? StorageClient.map(object: movieJson.data(using: .utf8), storageKey: "testing")
        XCTAssertNotNil(movie)
        XCTAssert(movie?.title == "The Green Mile")
        XCTAssert(movie?.year == "1999")
        XCTAssert(movie?.rated == "R")
        XCTAssertTrue(movie?.genre?.contains("Crime") ?? false)

        do {
            let stored: Movie? = try StorageClient.retrieve(storageKey: "testing")
            XCTAssertTrue(movie?.title == stored?.title)
            XCTAssertTrue(movie?.year == stored?.year)
            XCTAssertTrue(movie?.rated == stored?.rated)
            XCTAssertTrue(movie?.genre == stored?.genre)
        } catch {
            debugPrint(error.localizedDescription)
            XCTFail("Data retrieval failed")
        }
    }
    
    func testMoviesExample() {
        let movies: [Movie]? = try? StorageClient.map(object: movieJsonArray.data(using: .utf8), storageKey: "testingMovies" )
        XCTAssertNotNil(movies)
        XCTAssert(movies?.count ?? 0 == 2)

        guard let movie = movies?.first(where: { $0.title == "The Green Mile" }) else {
            XCTFail("No movies returned from storage")
            return
        }

        XCTAssert(movie.title == "The Green Mile")
        XCTAssert(movie.year == "1999")
        XCTAssert(movie.rated == "R")
        XCTAssertTrue(movie.genre?.contains("Crime") ?? false)
        
        moviesFetchExample(key: "testingMovies")
    }

    func moviesFetchExample(key: String) {
        let movies: [Movie]? = try? StorageClient.retrieve(storageKey: key)
        XCTAssertNotNil(movies)
        XCTAssert(movies?.count ?? 0 == 2)

        guard let movie = movies?.first(where: { $0.title == "The Green Mile" }) else {
            XCTFail("No movies returned from storage")
            return
        }

        XCTAssert(movie.title == "The Green Mile")
        XCTAssert(movie.year == "1999")
        XCTAssert(movie.rated == "R")
        XCTAssertTrue(movie.genre?.contains("Crime") ?? false)
    }
    
    func testSaveMovies() {
        guard let data = movieJsonArray.data(using: .utf8) else { return }
        let movies: [Movie]? = try? CoderModule.decoder.decode([Movie].self, from: data)
        XCTAssertNotNil(movies)
        XCTAssert(movies?.count ?? 0 == 2)

        guard let movie = movies?.first(where: { $0.title == "The Green Mile" }) else {
            XCTFail("No movies returned from storage")
            return
        }

        XCTAssert(movie.title == "The Green Mile")
        XCTAssert(movie.year == "1999")
        XCTAssert(movie.rated == "R")
        XCTAssertTrue(movie.genre?.contains("Crime") ?? false)
        
        try? movies?.save(storageKey: "testMovieManualSave", storageType: .fileManager)
        moviesFetchExample(key: "testMovieManualSave")
    }
    
}
