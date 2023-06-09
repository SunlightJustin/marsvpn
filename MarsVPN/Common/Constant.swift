//
//  Constant.swift
//
//  Created by Spike on 2019/09/16.
//

import UIKit


let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
let SCREEN_HEIGHT_THUMB = SCREEN_HEIGHT - IPHONEX_BOTTOM - NAVIGATIONBAR_HEIGHT
let SCREEN_HEIGHT_WITHOUT_TOP_BOTTOM_BAR = SCREEN_HEIGHT - TABBAR_HEIGHT - NAVIGATIONBAR_HEIGHT
let SCREEN_HEIGHT_SAFE_AREA = IS_IPHONEX ? UIScreen.main.bounds.size.height - IPHONEX_BOTTOM - STATUSBAR_HEIGHT : UIScreen.main.bounds.size.height

let IS_IPHONEX =  (SCREEN_HEIGHT >= 812.0 - 1 ? true : false)
let NAVIGATIONBAR_HEIGHT: CGFloat = IS_IPHONEX ? 88.0 : 64.0
let TABBAR_HEIGHT: CGFloat = IS_IPHONEX ? 49.0+34.0 : 49.0
let STATUSBAR_HEIGHT: CGFloat = IS_IPHONEX ? 44.0 : 20.0
let IPHONEX_BOTTOM: CGFloat = IS_IPHONEX ? 34.0 : 0
let IPHONEX_TOP: CGFloat = IS_IPHONEX ? 24.0 : 0
