//
//  Configuration.swift
//  GOGOVPN
//
//  Created by Justin on 2022/7/5.
//

import Foundation

//appleAppID
#if DEBUG
let AppleAppID = "1632843810"
let AppSpecificSharedSecret = "30a6b50bfe5041bf8948a94060935a87"
let AppGroup = "group.com.start.vpn"
let NetworkExtensionBundleIdSuffix = ".packagetunel"

//let AppleAppID = "1645738370"
//let AppSpecificSharedSecret = "0e1509dc8ea54a9093db181a5dbec684"
//let AppGroup = "group.com.warpvpn.data"
#else
let AppleAppID = "1645738370"
let AppSpecificSharedSecret = "0e1509dc8ea54a9093db181a5dbec684"
let AppGroup = "group.com.warpvpn.data"
let NetworkExtensionBundleIdSuffix = ".proxy"
#endif

// AppsFlyer
#if DEBUG
//let AppsFlyerDevKey = "jU2SSRKFJAbSJVN5LRLVki"
//let AppsFlyerDevKey = "ksyMY6dhDPcqkE7EsdGD6i"
#else
//let AppsFlyerDevKey = "ksyMY6dhDPcqkE7EsdGD6i"
#endif

let TERMS_USE = "https://warpvpn.pages.dev/terms"
let PRIVACY_POLICY = "https://warpvpn.pages.dev/privacy"
let SUPPORT_EMAIL = "marsvpn.net@gmail.com"
 
