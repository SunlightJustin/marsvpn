//
//  HUD.swift
//  FastVPN
//
//  Created by Justin on 2022/9/21.
//

import Foundation

protocol HUDProtocol {
    static func startLoading()
    static func hide(afterDelay: Double)
    static func flash(_ message: String)
}

class HUD: HUDProtocol {
    static func startLoading() {
        LXHUD.show(HUDContentType.systemActivity)
    }
    
    static func hide(afterDelay: Double=2) {
        LXHUD.hide(afterDelay: afterDelay)
    }
    
    static func flash(_ message: String) {
        LXHUD.flash(.label(message))
    }
}


