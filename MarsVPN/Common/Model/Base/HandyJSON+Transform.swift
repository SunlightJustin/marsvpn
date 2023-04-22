//
//  HandyJSON+Extension.swift
//  Kinker
//
//  Created by clove on 8/1/20.
//  Copyright © 2020 personal.Justin. All rights reserved.
//

import Foundation
import HandyJSON

extension String: HandyJSON {
    
}

extension Dictionary: HandyJSON {
    
}

extension Array: HandyJSON {
    
}

extension NSNull: HandyJSON {
    
}

open class TimeDateFormatterTransform: TransformType {
    public typealias Object = Date
    public typealias JSON = Int

    open func transformFromJSON(_ value: Any?) -> Date? {
        if let time = value as? Int {
            return Date(timeIntervalSince1970: TimeInterval(time)/1000)
        }
        return nil
    }

    open func transformToJSON(_ value: Date?) -> Int? {
        if let date = value {
            return Int(date.timeIntervalSince1970*1000)
        }
        return nil
    }
}

