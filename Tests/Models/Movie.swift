//
//  Movie.swift
//  SimpleAPIClient iOS Tests
//
//  Created by Rich Mucha on 20/03/2019.
//  Copyright © 2019 RichAppz Limited. All rights reserved.
//

import Foundation

public struct Movie: Model {
    
    public let title: String?
    public let year: String?
    public let rated: String?
    public let genre: String?
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case rated = "Rated"
        case genre = "Genre"
    }
    
    public static var storageIdentifier: String {
        return "movie"
    }
    
    public static var identifier: String {
        return "title"
    }
    
}
