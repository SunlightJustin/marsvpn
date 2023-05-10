//
//  AppInfo.swift
//
//  Created by Spike on 2019/09/16.
//

import Foundation
import KeychainAccess
import AFDateHelper

enum AppInfo {

    static let displayName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""
    static let shortDisplayName: String = displayName.replacingOccurrences(of: " ", with: "")
    static let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    static let buildVersion: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
    static let bundleIdentifier: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""

    #if DEBUG || ADHOC
//    static let uniquePrefix = "app.dd.rr"
    static let uniquePrefix = "yywekddeer"

    #else
    /**
    Note: 第一次发版是这个值，绝对绝对 不能再修改
     
    static let uniquePrefix = "yywekdde"
     */
    static let uniquePrefix = "yywekdde"
    #endif

    static let keychainService = uniquePrefix + "keychain.service"

    static let deviceIdKey = uniquePrefix + "keychain.deviceIdkey"
    static let deviceId: String = {
        let keychain = Keychain(service: keychainService)
//        #if DEBUG
//        #else
        if let deviceId = keychain[deviceIdKey],
            deviceId.count > 0 {
            return deviceId
        }
//        #endif

        var deviceId = UIDevice.current.identifierForVendor?.uuidString

        if deviceId == nil || deviceId?.count == 0 {
            deviceId = NSUUID().uuidString
        }
        
        deviceId = (deviceId ?? "") + (CountryCode.telephonyCountryCode ?? "NA") + "_" + Date().toString(format: .custom("yyyyMMddHHmm"), timeZone: .utc)

        keychain[deviceIdKey] = deviceId

        return deviceId ?? ""
    }()
    
    static let shortDeviceId: String = {
        return String(deviceId.prefix(8) + deviceId.suffix(15))
    }()

    static let registerDate: Date = {
        guard let str = deviceId.components(separatedBy: "_").last else { return Date() }
        guard let date = Date(fromString: str, format: .custom("yyyyMMddHHmm"), timeZone: .utc) else { return Date() }
        debugPrint("register date = ", date)
        return date
    }()
}
