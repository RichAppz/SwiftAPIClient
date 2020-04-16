# SwiftAPIClient

SwiftAPIClient is a network layer that contains Alamofire and enables the ability to quickly implement your API calls.

The framework includes offline capabilites by storing your json data on the device so recall as and when required. Examples below.

## Introduction

This framework has been developed to help make development faster and more efficient. After using CoreData/Realm for storing offline data for simple data applications, it was identified that there was a requirement to reducing the need for complicated datastores and helping to reduce app bundle sizes.

## Requirements

- iOS 10.0+ / macOS 10.13+ / tvOS 10.0+ / watchOS 3.0+
- Xcode 10.1+
- Swift 4.2+

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate Alamofire into your Xcode project using CocoaPods, specify it in your `Podfile`:

Current working on codable models, to beta test this please use 
```ruby
pod 'SwiftAPIClient', '~> 1.1.0'
```

Otherwise stick to this version
```ruby
pod 'SwiftAPIClient', '1.0.0'
```

### Implementation

```swift
import SwiftAPIClient
```

#### Client 

A client is required to create the required Gateway - you can create a multitude of these if connecting to a variety of servers and authentications.

``` swift
class ClientExample: Service {

    //================================================================================
    // MARK: Properties
    //================================================================================

    var rootURL = "<YOUR ENDPOINT>"
    var headers: [String: String] = [:]
    let networkQueue = OperationQueue()

    //================================================================================
    // MARK: Singleton
    //================================================================================

    static let shared = ClientExample()

    //================================================================================
    // MARK: Initialization
    //================================================================================

    init() { }

    //================================================================================
    // MARK: Helpers
    //================================================================================

    func post(_ request: Request, completion: OperationResponse? = nil) {
        makeRequest(.post, request: request, completion: completion)
    }

    func get(_ request: Request, completion: OperationResponse? = nil) {
        makeRequest(.get, request: request, completion: completion)
    }

    func delete(_ request: Request, completion: OperationResponse? = nil) {
        makeRequest(.delete, request: request, completion: completion)
    }

    func put(_ request: Request, completion: OperationResponse? = nil) {
        makeRequest(.put, request: request, completion: completion)
    }

    func patch(_ request: Request, completion: OperationResponse? = nil) {
        makeRequest(.patch, request: request, completion: completion)
    }

}
```
#### Model Example

Using the `Model` generic class enables the framework to store and retrieve your models.

```swift
public struct Movie: Model {

    public let title: String?
    public let year: Int?
    public let rated: String?
    public let genre: [String]?

    public init?(json: [String: Any]) {
        title = json["Title"] as? String
        year = json["Year"] as? Int
        rated = json["Rated"] as? String
        genre = json["Genre"] as? [String]
    }

    public static var storageIdentifier: String {
        return "movie"
    }

    public static var identifier: String {
        return "title"
    }

}
```

#### Endpoint Func Example

```swift
extension Service {
    
    public func fetchMovieWith(query: String, completion: @escaping ((Movie?, Error?) -> Void)) {
        get(Request(
            endpoint: "",
            parameters: ["t": query],
            priority: .high,
            qualityOfService: .default)
        ) { (response) in
                let movie: Movie? = StorageClient.map(object: response.json)
                DispatchQueue.main.async {
                    completion(movie, response.error)
                }
        }
    }
    
}
```

#### Data Retrieval Example

```swift
let account: Account? = StorageClient.retrieve()
let accounts: [Account]? = StorageClient.retrieve()
```

## Licence (Mit)

Copyright (c) 2017-2019 RichAppz Limited (https://richappz.com)

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.


------------

Rich Mucha, RichAppz Limited
rich@richappz.com
