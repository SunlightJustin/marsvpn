//
//  GGAnalyticsManager+convenience.swift
//  SDM
//
//  Created by clove on 5/29/19.
//  Copyright © 2019 MS. All rights reserved.
//

import Foundation
//import FirebaseAnalytics
import Flurry_iOS_SDK

typealias AnalyticsManager = GGAnalyticsManager

class GGAnalyticsManager {
    static let sharedInstance = GGAnalyticsManager()
    var cache = [String: Any]()
    
    public class func setUserID(_ userId: String?) {
//        Analytics.setUserID(userId)
        Flurry.set(userId: userId)
    }
        
    public class func logEvent(_ event0: String, value: Any?=nil) {
        logEvent(event0, event1: "", value: value)
    }
    
    public class func logEvent(_ event0: String, event1: String, value: Any?=nil) {
        guard event0.count > 0 else { return }
        if event1.count > 0 {
            let status = Flurry.log(eventName: event0, parameters: [event1: value ?? "NA"])
            debugPrint("Flurry event \(event0), parameters = \([event1: value ?? "NA"]), status \(status)")
        } else {
            let status = Flurry.log(eventName: event0, parameters: nil)
            debugPrint("Flurry event \(event0), status \(status)")
        }
    }

//    public class func logEvent(_ model: AnalyticsModel?, value: Any?=nil) {
//        self.logEvent(withModel: model, value: value)
//    }

    public class func logEvent(_ event0s: [String], values: [String]?=nil, index:Int) {
        if index < event0s.count {
            let event0 = event0s[index]
            
            var value:Any?
            if let array = values, index < array.count {
                value = array[index]
            }
            
            self.logEvent(event0, value: value)
        }
    }
    
    public class func logEvent(_ event0s: [String], event1s: [String]?=nil, values: [Any]?=nil, index:Int) {
        if index < event0s.count {
            let event0 = event0s[index]
            
            var event1:String?
            if let array = event1s, index < array.count {
                event1 = array[index]
            }
            
            var value:Any?
            if let array = values, index < array.count {
                value = array[index]
            }
            
            if let event1Value = event1 {
                self.logEvent(event0, event1: event1Value, value: value)
            } else {
                self.logEvent(event0, value: value)
            }
        }
    }
}

extension GGAnalyticsManager {
    
    public enum CacheKey: String {
    case payment_open_from = "payment_open_from"
    }

    public class func cache(_ event1: String?, with key: CacheKey) {
        self.sharedInstance.cache[key.rawValue] = event1
    }
    
    private func removeCache(key: CacheKey) {
        self.cache.removeValue(forKey: key.rawValue)
    }
    
    private func cachedEvent1(key: CacheKey) -> String? {
        return self.cache[key.rawValue] as? String
    }

    public class func logEvent(event0: String, event1 cacheKey: CacheKey?=nil) {
        var event1: String?
        var value: String?
        if let key = cacheKey {
            event1 = key.rawValue
            value = self.sharedInstance.cachedEvent1(key: key)
//            self.sharedInstance().removeCache(key: key)
        }
        
        if let event1 = event1 {
            self.logEvent(event0, event1: event1, value: value)
        } else {
            self.logEvent(event0)
        }
    }

}
