# SwiftAPIClient-SDK

SwiftAPIClient is a network layer that enables the ability to quickly implement your server API calls.

The framework includes offline capabilites by storing your json data on the device so recall as and when required. Examples below.

## Introduction

This framework has been developed to help make development faster and more efficient. After using CoreData/Realm for storing offline data for simple data applications, it was identified that there was a requirement to reducing the need for complicated datastores and helping to reduce app bundle sizes.

## Features

The project has been built upon over a long period of time and is used in many projects

- The project uses Swift's Codable Protocols and all models will conform to Codable. 
- The framework has a mechanism to fetch JSON resource files that should be used for DEMO and testing purposes.
- There is a storage mechanism that will store the data responses into either UserDefaults , FileManager or not at all, each request is configurable. The are setting to enable SHA256 encoding of this data to ensure the data stored is secure.
- There is a mechanism in the framework to monitor the network status, if there is no connection then all calls will be routed to the last call received and if the data is available it will be passed back, this ensures that the framework can handle offline out of the box.
- The framework has a new ClosureService which handle duplications of calls, if the app requests exactly the same call multiple times before the inital is finished the the framework will stop further calls but complete all blocks.

Sounds like alot to remember! So there are simple helpers that have been setup that do all the above for you so you don't have to remember.

## Supports

- iOS 10.0+ / macOS 10.13+ / tvOS 10.0+ / watchOS 3.0+

## Requirements

- Xcode 11.0+
- Swift 4.2+

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate SwiftAPIClient into your Xcode project using CocoaPods, specify it in your `Podfile`:
 
```ruby
pod 'SwiftAPIClient'
```

### Implementation

```swift
import SwiftAPIClient
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding SwiftAPIClient as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/RichAppz/SwiftAPIClient-SDK.git", .upToNextMajor(from: "1.0.3"))
]
```

#### Client 

A client is required to create the required Gateway - you can create a multitude of these if connecting to a variety of servers and authentications.

``` swift
class ClientExample: Service {

    // ==========================================
    // MARK: Properties
    // ==========================================

    var rootURL = "<YOUR ENDPOINT>"
    var headers: [String: String] = [:]
    let networkQueue = OperationQueue()

    // ==========================================
    // MARK: Singleton
    // ==========================================

    static let shared = ClientExample()

    // ==========================================
    // MARK: Initialization
    // ==========================================

    init() { }

    // ==========================================
    // MARK: Helpers
    // ==========================================

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

The CoderModule has been setup to be able to do a bunch of things to help parse JSON data:

```swift
DateDecodingStrategy - handling various date formats
enum DateType: String {
    case iso8601x = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    case iso8601 = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    case java = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
    case javaSimple = "yyyy-MM-dd HH:mm:ss Z"
    case simple = "yyyy-MM-dd"
    
    static let formats: [DateType] = [iso8601x, iso8601, java, javaSimple, simple]
}
```

- KeyDecodingStrategy - handling endpoints that contain snakecase/camelcase parameters without any thought about it.

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
            parameters: ["t": query])
        ) { (response) in
            let movie: Movie? = try? StorageClient.map(object: response.data)
            DispatchQueue.main.async {
                completion(movie, response.error)
            }
        }
    }
    
}
```

#### Data Retrieval Example

```swift
let account: Account? = try? StorageClient.retrieve()
let accounts: [Account]? = try? StorageClient.retrieve()
```

## Extras

The feature list is rather big and writing your requests can be time consuming so try out the extensions that have been created that allow you to do this:

```swift
extension Service {

    public func fetchMovieWith(query: String, completion: @escaping ((Movie?, Error?) -> Void)) {
        stdGetRequest(
            RequestModel(
                params: ["t": query],
                storageType: .fileManager),
            completion: completion
        )
    }
    
}
```

The completion should always conform to either of the following IF you want to use the stdGetRequest, stdPostRequest helpers (otherwise you can create your own manual requests)

```swift 
((Model?, Error?) -> Void)?
(([Model]?, Error?) -> Void)?
```

The `stdGetRequest` has various properties that can be set for your request (there are post as well):

`endpoint` - the enum that you setup
`endpointParam` - parameter that needs to go in your endpoint, eg venues/%@
`params` - the json body that needs to be sent with the request
`storageType` - where you can specify what storage you want
`storageAdditionKey` - this is extra parameters you want to inject into the storage to identify the request for example the id of a venue or the paging parameters, allowing the storage to identify the data.
`notification` - the Notification.Name that you setup
`completion` - pass the completion block straight in

All the parameters are optional or have defaults you can check the code to see this.

Both `stdGetRequest` and `stdPostRequest` handles all the features that was mentioned above and should be used over a manual route.

## Licence (Mit)

Copyright (c) 2017-2020 RichAppz Limited (https://richappz.com)

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
