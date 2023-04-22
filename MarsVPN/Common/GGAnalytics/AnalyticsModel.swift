//
//  AnalyticsModel.swift
//  SDM
//
//  Created by clove on 5/29/19.
//  Copyright © 2019 MS. All rights reserved.
//

import Foundation

public class AnalyticsModel: AnalyticsProtocol {
    public func event0() -> String! {
        return _event0
    }
    
    public func event1() -> String! {
        return _event1
    }
    
    public func value() -> Any! {
        return _value
    }
    
    var _event0:String
    var _event1:String?
    var _value:Any?
    
    
//    init(_ event0: String, dictionary: Dictionary<String,Any>) {
//        self._event0 = event0
//        self.event1 = dictionary["event1"] as? String
//        self.value = dictionary["value"]
//    }
    
    private init() {
        self._event0 = ""
    }
    
    public convenience init?(_ event0: String) {
        self.init()
//        if let dictionary = GGAnalyticsManager.dictionary(withEvent0: event0) {
//            self.init()
//            self._event0 = event0
//            self._event1 = dictionary["event1"] as? String
//            self._value = dictionary["value"]
//        } else {
//            return nil
//        }
    }
}

