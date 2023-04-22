//
//  NSTimer+SwiftBlocksKit.swift
//  SwiftBlocksKit
//
//  Created by sy on 2017/9/24.
//  Copyright © 2017年 sy. All rights reserved.
//

import Foundation

fileprivate class TimerActor {
    let block: (Timer) -> Void
    init(block: @escaping (Timer) -> Void) {
        self.block = block
    }
    
    @objc func fire(sender: Timer) {
        block(sender)
    }
}

fileprivate extension Selector {
    static let fire = #selector(TimerActor.fire(sender:))
}

extension SwiftBlocksKit where Base: Timer {
    
    @discardableResult
    public static func scheduledTimer(withTimeInterval interval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Swift.Void) -> Timer {
        let actor = TimerActor(block: block)
        return Timer.scheduledTimer(timeInterval: interval, target: actor, selector: .fire, userInfo: nil, repeats: repeats)
    }
    
    @discardableResult
    public static func timer(withTimeInterval interval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Swift.Void) -> Timer {
        let actor = TimerActor(block: block)
        return Timer(timeInterval: interval, target: actor, selector: .fire, userInfo: nil, repeats: repeats)
    }
}




//@available(iOS 10.0, *)
//public /*not inherited*/ init(timeInterval interval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Swift.Void)
//
//
//@available(iOS 10.0, *)
//open class func scheduledTimer(withTimeInterval interval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Swift.Void) -> Timer

