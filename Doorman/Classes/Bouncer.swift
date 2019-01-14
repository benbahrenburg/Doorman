//
//  Bouncer.swift
//
//
//  Created by Ben Bahrenburg on 10/23/16.
//  Copyright © 2018 bencoding.com. All rights reserved.
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
    
    public func exists(jobLabel: String) -> Bool {
        var exists: Bool = false
        guard let q = queue else { return exists }
        q.async {[weak self] in
            exists = self?.timeCache[jobLabel] != nil ? true : false
        }
        return exists
    }
    
    public func add(jobLabel: String, threshold: TimeInterval) {
        guard let q = queue else { return }
        q.async(flags: .barrier) {[weak self] in
            self?.timeCache[jobLabel] = Date()
        }
    }
    
    public func thresholdReached(jobLabel: String, threshold: TimeInterval) -> Bool {
        var reached = false
        if !exists(jobLabel: jobLabel) {
            add(jobLabel: jobLabel, threshold: threshold)
            return reached
        }
        
        guard let q = queue else { return reached }
        q.sync {[weak self] in
            let timeInterval = Date().timeIntervalSince(self?.timeCache[jobLabel] ?? .distantPast)
            if threshold > timeInterval {
                reached = true
            }
        }
        
        return reached
    }
    
    public func inspect(jobLabel: String, threshold: TimeInterval, closure: @escaping (Bool) -> Void) {
        guard let q = queue else { return }
        q.async {[weak self] in
            let reached = self?.thresholdReached(jobLabel: jobLabel, threshold: threshold)  ?? true
            reached ?  closure(false) :  closure(true)
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
        q.async(flags: .barrier) {[weak self] in
            if self?.timeCache[byJobLabel] != nil {
                self?.timeCache.removeValue(forKey: byJobLabel)
            }
        }
    }
    
    public func reset() {
        guard let q = queue else { return }
        q.async(flags: .barrier) {[weak self] in
            self?.timeCache.removeAll()
        }
    }
    
}
