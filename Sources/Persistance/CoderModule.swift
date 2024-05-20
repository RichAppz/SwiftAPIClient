//
//  CoderModule.swift
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

enum DateType: String {
    case iso8601x = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    case iso8601 = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    case java = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
    case javaSimple = "yyyy-MM-dd HH:mm:ss Z"
    case simple = "yyyy-MM-dd"
    
    static let formats: [DateType] = [iso8601x, iso8601, java, javaSimple, simple]
}

public class CoderModule {
    
    // ==================================================
    // MARK: Private Properties
    // ==================================================
    
    private static let jsonDecoder = JSONDecoder()
    private static let jsonEncoder = JSONEncoder()
    
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()
    
    // ==================================================
    // MARK: Public Properties
    // ==================================================
    
    /**
     Custom decoder that will help map the response data to a specific set of rules: 5 optional date strings, snakeCase > Camel if required
     ~ if forking the framework you can adjust to your own decode options
     
     - Returns: JSONDecoder
     */
    public static var decoder: JSONDecoder = {
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            
            if let dateTimestamp = try? container.decode(TimeInterval.self) {
                let currentTimestamp = Date().timeIntervalSince1970
                if dateTimestamp/currentTimestamp > 500 {
                    return Date(timeIntervalSince1970: dateTimestamp/1000)
                } else {
                    return Date(timeIntervalSince1970: dateTimestamp)
                }
            }
            
            let dateString = try container.decode(String.self)
            for format in DateType.formats {
                formatter.dateFormat = format.rawValue
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        }
        return jsonDecoder
    }()
    
    /**
     Custom encoder that will help map the Model<T> to a specific set of rules:  Camel if required > snakeCase
     ~ if forking the framework you can adjust to your own decode options
     
     - Returns: JSONEncoder
     */
    public static var encoder: JSONEncoder = {
        jsonEncoder.dateEncodingStrategy = .secondsSince1970
        return jsonEncoder
    }()
    
}
