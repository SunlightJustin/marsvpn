//
//  UIButton+SwiftBlocksKit.swift
//  BL
//
//  Created by sy on 2017/9/24.
//  Copyright © 2017年 sy. All rights reserved.
//

import UIKit

private var conrtolHandlerKey: Void?

extension SwiftBlocksKit where Base: UIControl {
    public func addEventHandlerForControlEvents(_ controlEvents: UIControl.Event, block: @escaping ((Base) -> Void)) {
        let key = NSNumber(value: controlEvents.rawValue)
        var handlers = events[key] as? NSMutableSet
        if nil == handlers {
            handlers = NSMutableSet()
            events[key] = handlers
        }
        let selector = #selector(SwiftBlocksKitControlWrapper.invoke(_:))
        let target = SwiftBlocksKitControlWrapper(controlEvents: controlEvents, block: block)
        handlers?.add(target)
        base.addTarget(target, action: selector, for: controlEvents)
    }
    
    public func removeEventHandlersForControlEvents(_ controlEvents: UIControl.Event) {
        let key = NSNumber(value: controlEvents.rawValue)
        
        guard let handlers = events[key] as? NSMutableSet else {
            return
        }
        
        handlers.forEach {
            guard let element = $0 as? UIControl else { return }
            base.removeTarget(element, action: nil, for: controlEvents)
        }
        events.removeObject(forKey: key)
    }
    
    public func hasEventHandlersForControlEvents(_ controlEvents: UIControl.Event) -> Bool {
        let key = NSNumber(value: controlEvents.rawValue)
        guard let handlers = events[key] as? NSMutableSet else {
            return false
        }
        
        return handlers.count != 0
    }
    
    fileprivate var events: NSMutableDictionary {
        var dictionary = objc_getAssociatedObject(base, &conrtolHandlerKey) as? NSMutableDictionary
        if nil == dictionary {
            dictionary = NSMutableDictionary()
            setEvents(dictionary!)
        }
        return dictionary!
    }
    
    fileprivate func setEvents(_ events: NSMutableDictionary) {
        objc_setAssociatedObject(base, &conrtolHandlerKey, events, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    // SwiftBlocksKitContrilWrapper
    fileprivate class SwiftBlocksKitControlWrapper: NSObject, NSCopying {
        let controlEvents: UIControl.Event
        let block: (Base)-> Void
        init(controlEvents: UIControl.Event, block: @escaping (Base)-> Void) {
            self.controlEvents = controlEvents
            self.block = block
        }
        
        func copy(with zone: NSZone? = nil) -> Any {
            return SwiftBlocksKitControlWrapper(controlEvents: controlEvents, block: block)
        }
        
        @objc func invoke(_ sender: Any) {
            guard let sender = sender as? Base else { return }
            block(sender)
        }
    }
}



