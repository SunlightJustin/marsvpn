//
//  GGTools.swift
//  GOGOVPN
//
//  Created by Justin on 2022/9/26.
//

import Foundation
import CoreTelephony

class CountryCode {
    private static let shared = CountryCode()

    static let carrierName = shared._carrierName

    static var isCN_IR: Bool {
//        #if DEBUG
//        return false
//        #endif
        return CountryCode.countryCode == "CN" || CountryCode.countryCode == "IR"
    }
    static var isCN: Bool {
        return CountryCode.countryCode == "CN"
    }
    static var hasTelephoneAndIsNot_CN_IR: Bool {
        guard let countryCode = CountryCode.telephonyCountryCode else { return false }
//        #if DEBUG
//        return false
//        #endif
        return  countryCode != "CN" && countryCode != "IR"
    }
    static var countryCode: String? {
        var str: String?
        if let code = shared._telephonyCountryCode {
            str = code
        } else if let code = shared._networkCountryCode {
            str = code
        } else if let code = shared._localCountryCode {
            str = code
        }
//        debugPrint("CountryCode.CountryCode = \(str)")
        return str
    }
    private var _networkCountryCode: String?
    static var networkCountryCode: String? {
        get {
            return shared._networkCountryCode
        }
        set {
            shared._networkCountryCode = newValue
        }
    }

    static var telephonyCountryCode: String? {
        return shared._telephonyCountryCode
    }
    private lazy var _telephonyCountryCode: String? = {
//#if DEBUG
//    return "US"
//#endif

       let telephonyInfo: CTTelephonyNetworkInfo = CTTelephonyNetworkInfo()
       if let carrierNetwork: String = telephonyInfo.currentRadioAccessTechnology {
           debugPrint("mobile network : \(carrierNetwork)")
       }

           let carrier = telephonyInfo.subscriberCellularProvider

           let countryCode = carrier?.mobileCountryCode
        debugPrint("country code:\(String(describing: countryCode))")

           let mobileNetworkName = carrier?.mobileNetworkCode
        debugPrint("mobile network name:\(String(describing: mobileNetworkName))")

           let carrierName = carrier?.carrierName
        debugPrint("carrierName is : \(String(describing: carrierName))")

           let isoCountrycode = carrier?.isoCountryCode
           debugPrint("iso country code: \(String(describing: isoCountrycode))")
        
        if let isoCountrycode = isoCountrycode, isoCountrycode.isEmpty == false {
            return isoCountrycode.uppercased()
        }
       
       return nil
    }()
    
    private lazy var _localCountryCode: String? = {
        if let countryCode = Locale.current.regionCode {
            debugPrint("Locale.current.regionCode: \(String(describing: countryCode))")
            return countryCode.uppercased()
        }
        return nil
    }()

    
    private lazy var _carrierName: String? = {
        let telephonyInfo: CTTelephonyNetworkInfo = CTTelephonyNetworkInfo()
        let carrier = telephonyInfo.subscriberCellularProvider
         if let carrierName = carrier?.carrierName, let isoCountrycode = carrier?.isoCountryCode, isoCountrycode.isEmpty == false {
             return "\(carrierName)_\(isoCountrycode)"
         }
        return nil
     }()
     
    
//    static func countryCode() -> String? {
//        let telephonyInfo: CTTelephonyNetworkInfo = CTTelephonyNetworkInfo()
//           let carrierNetwork: String = telephonyInfo.currentRadioAccessTechnology!
//        debugPrint("mobile network : \(carrierNetwork)")
//
//           let carrier = telephonyInfo.subscriberCellularProvider
//
//           let countryCode = carrier?.mobileCountryCode
//        debugPrint("country code:\(String(describing: countryCode))")
//
//           let mobileNetworkName = carrier?.mobileNetworkCode
//        debugPrint("mobile network name:\(String(describing: mobileNetworkName))")
//
//           let carrierName = carrier?.carrierName
//        debugPrint("carrierName is : \(String(describing: carrierName))")
//
//           let isoCountrycode = carrier?.isoCountryCode
//           debugPrint("iso country code: \(String(describing: isoCountrycode))")
//
//        if let isoCountrycode = isoCountrycode, isoCountrycode.isEmpty {
//            if let countryCode = Locale.isoRegionCodes.first {
//                debugPrint("Locale.isoRegionCodes: \(String(describing: Locale.isoRegionCodes))")
//                return countryCode
//            } else {
//                return nil
//            }
//        } else {
//            return isoCountrycode
//        }
//    }
}
