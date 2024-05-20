//
//  NetworkStatusService.swift
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

public protocol NetworkObserver: AnyObject {
    func networkAvailabilityChanged()
}

public class NetworkStatusService {
    
    // ==========================================
    // MARK: Properties
    // ==========================================
    
    fileprivate struct _NetworkObserver {
        
        weak var observer: NetworkObserver?
        
        func fire() {
            self.observer?.networkAvailabilityChanged()
        }
        
        var isValid: Bool {
            return observer != nil
        }
        
    }
    
    fileprivate var reachability: Reachability?
    fileprivate var runningNetworkTasks = [NSObject: Timer]()
    fileprivate var observers = [_NetworkObserver]()
    
    fileprivate var isOnline: Bool {
        return self.reachability?.currentReachabilityStatus != .notReachable
    }
    
    // ==========================================
    // MARK: Singleton
    // ==========================================
    
    internal static let shared = NetworkStatusService()
    internal init() {
        do {
            reachability = Reachability()
            try reachability?.startNotifier()
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
        }
        
        NotificationCenter.default.addObserver(
            forName: ReachabilityChangedNotification,
            object: reachability,
            queue: nil, using: { _ in
                DispatchQueue.main.async {
                    for wrapper in self.observers {
                        wrapper.fire()
                    }
                    self.observers = self.observers.filter { $0.isValid }
                }
        })
    }
    
    // ==========================================
    // MARK: Helpers
    // ==========================================
    
    /**
     Confirms if the device has a network connection available
     
     - Returns: Bool
     */
    public static var hasConnection: Bool {
        return shared.isOnline
    }
    
    /**
     Appends a NetworkObserver delegate to the Singleton store
     */
    public class func startObservingNetworkChanges(_ newObserver: NetworkObserver) {
        let obs = _NetworkObserver(observer: newObserver)
        shared.observers.append(obs)
    }
    
    /**
     Removes a NetworkObserver delegate from the Singleton store
     */
    public class func stopObservingNetworkChanges(_ observer: NetworkObserver) {
        var idx: Int?
        for (i, wrapper) in shared.observers.enumerated() {
            if wrapper.isValid && wrapper.observer === observer {
                idx = i
                break
            }
        }
        
        if let index = idx {
            shared.observers.remove(at: index)
        }
    }
    
}
