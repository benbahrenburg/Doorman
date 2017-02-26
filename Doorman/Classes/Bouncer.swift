//
//  Bouncer.swift
//
//
//  Created by Ben Bahrenburg on 10/23/16.
//  Copyright © 2016 bencoding.com. All rights reserved.
//

import Foundation

public class Bouncer {
    
    fileprivate let queue: DispatchQueue?
    fileprivate var timeCache = [String: Date]()
    
    public class var sharedInstance: Bouncer {
        struct Static {
            static let instance = Bouncer()
        }
        
        return Static.instance
    }
    
    public init(queueLabel: String = "com.bencoding.doorman.bouncer") {
        queue = DispatchQueue(label: queueLabel, attributes: [.concurrent])
    }
    
    @discardableResult public func inspect(jobLabel: String, threshold: TimeInterval, closure: @escaping (Bool) -> Void) {
        guard queue != nil else { return }
        
        let should = queue!.sync { () -> Bool in
            let now = Date()
            let timeInterval = now.timeIntervalSince(timeCache[jobLabel] ?? .distantPast)
            if timeInterval > threshold {
                timeCache[jobLabel] = now
                return true
            }
            return false
        }
        queue!.async {
            closure(should)
        }
    }
    
    @discardableResult public func debounce(jobLabel: String, threshold: TimeInterval, closure: @escaping () -> Void) {
        guard queue != nil else { return }
        inspect(jobLabel: jobLabel, threshold: threshold, closure: {[weak self] (should: Bool) in
            if should {
                self?.queue!.async {
                    closure()
                }
            }
        })
    }
    
    public func reset(byJobLabel: String) {
        guard queue != nil else { return }
        queue!.sync {
            if timeCache[byJobLabel] != nil {
                _ = timeCache.removeValue(forKey: byJobLabel)
            }
        }
    }
    
    public func reset() {
        guard queue != nil else { return }
        queue!.sync {
            timeCache.removeAll()
        }
    }
    
}
