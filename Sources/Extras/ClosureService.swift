//
//  ClosureService.swift
//  SimpleAPIClient
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

public typealias ModelObjectCompletionBlock<T: Model> = (T?, Error?) -> Void
public typealias ModelArrayCompletionBlock<T: Model> = ([T]?, Error?) -> Void

public struct Closure<T: Model>: Equatable {

    public let id: String
    public let blockObj: ModelObjectCompletionBlock<T>?
    public let blockArr: ModelArrayCompletionBlock<T>?

    /**
     Initialize the model with either the `ModelObjectCompletionBlock` or `ModelArrayCompletionBlock`
     - Parameter url: String - this should be an identifiable solution to the closure that can be referenced at API completion
     - Parameter params: [String: Any]? - the parameters that will be in the request, this is used alongside the url to create a key for the closure
     - Parameter blockObj: ModelObjectCompletionBlock
     - Parameter blockArr: ModelArrayCompletionBlock
     */
    init(url: String, params: [String: Any]? = nil, blockObj: ModelObjectCompletionBlock<T>? = nil, blockArr: ModelArrayCompletionBlock<T>? = nil) {
        let key = params?.jsonString?.ccSHA256 ?? ""
        
        self.id = url + key
        self.blockObj = blockObj
        self.blockArr = blockArr
    }

    static public func == (lhs: Closure, rhs: Closure) -> Bool {
        return lhs.id == rhs.id
    }

}

/**
This service allows the Client, if required, to stop quick succession API calls requesting the same data. The store
- Parameter store:  Array<Any>  - publicly available to allow for testing, use the functions to request the store
*/
public class ClosureService {

    // ================================================================================
    // MARK: Properties
    // ================================================================================

    public var store = ThreadSafeArray<Any>()

    // ================================================================================
    // MARK: Singleton
    // ================================================================================

    public static let shared = ClosureService()

    // ================================================================================
    // MARK: Helpers
    // ================================================================================

    /**
     Generic <Model> - Checks to see if an existing callback exists in the Singleton store, appends the callback to the array for outside methods to complete
     - Parameter closure:   `Closure<Model>`
     - Returns: Bool
     */
    static func contains<T: Model>(_ closure: Closure<T>) -> Bool {
        let isContained = shared.store.first(where: { $0 as? Closure<T> == closure }) != nil
        shared.store.append(closure)
        return isContained
    }
    
    /**
     Generic <Model> - Returns any matching closures that exist in the Singleton store
     - Parameter closure: `Closure<Model>`
     - Returns: Array(Closure<Model>)
     */
    static func closures<T: Model>(_ closure: Closure<T>) -> [Closure<T>] {
        let closures = shared.store.filter({ $0 as? Closure<T> == closure }) as? [Closure<T>] ?? []
        removeClosures(closures)
        return closures
    }
    
    /**
     Generic <Model> - Removes the closure from the Singleton store
     - Parameter closure:   `Closure<Model>`
     - Returns: Array(Closure<Model>)
     */
    static func removeClosures<T: Model>(_ closures: [Closure<T>]) {
        closures.forEach { (closure) in
            shared.store.remove(where: { $0 as? Closure<T> == closure })
        }
    }
    
    /**
     Clears the Singleton store
     */
    public static func clear() {
        shared.store = ThreadSafeArray<Any>()
    }

}
