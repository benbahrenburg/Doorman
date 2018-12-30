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
    
    public func reached(jobLabel: String, threshold: TimeInterval) -> Bool {
        var reached = false
        guard let q = queue else { return reached }
        q.sync {[weak self] in
            let timeInterval = Date().timeIntervalSince(self?.timeCache[jobLabel] ?? .distantPast)
            if timeInterval > threshold {
                self?.timeCache[jobLabel] = Date()
                reached = true
            }
        }
        return reached
    }
    
    public func inspect(jobLabel: String, threshold: TimeInterval, closure: @escaping (Bool) -> Void) {
        guard let q = queue else { return }
        q.async {[weak self] in
            let should = self?.reached(jobLabel: jobLabel, threshold: threshold)  ?? true
            should ?  closure(true) :  closure(false)
        }
    }
    
    public func debounce(jobLabel: String, threshold: TimeInterval, closure: @escaping () -> Void) {
        guard let q = queue else { return }
        inspect(jobLabel: jobLabel, threshold: threshold, closure: {(should: Bool) in
            if should {
                q.async {
                    closure()
                }
            }
        })
    }
    
    public func reset(byJobLabel: String) {
        guard let q = queue else { return }
        q.sync {
            if timeCache[byJobLabel] != nil {
                _ = timeCache.removeValue(forKey: byJobLabel)
            }
        }
    }
    
    public func reset() {
        guard let q = queue else { return }
        q.sync {
            timeCache.removeAll()
        }
    }
    
}
