//
//  MVIAPManager+Ab.swift
//  MarsVPN
//
//  Created by Justin on 2022/12/6.
//

import Foundation
import SwiftyStoreKit
import StoreKit

extension MVIAPManager {
    
    static func checkPurchaseIfCanMakePayments() {
        guard shared.canMakePayments() else { return }
        guard MVConfigModel.expireDate != nil else { return }
        shared.hasPurchaseSubscriptions { result, errMsg, date in
            debugPrint("static func checkPurchaseIfCanMakePayments, result=\(result), errMsg = \(errMsg), date=\(date)")
            if result {
                shared.purchasedSubscriptions = result
            }
            MVConfigModel.expireDate = date
        }
    }
    
    static func hasPurchaseSubscriptions(completion: @escaping (Bool, String?, Date?)->()) {
        shared.hasPurchaseSubscriptions { result, errMsg, date in
            debugPrint("static func hasPurchaseSubscriptions, result=\(result), errMsg = \(errMsg), date=\(date)")
            if result {
                shared.purchasedSubscriptions = result
            }
            MVConfigModel.expireDate = date
            
            if MVConfigModel.isVIP() {
                MVDataManager.fetchLocationListWhenUserBecomeVIP()
            }
            completion(result, errMsg, date)
        }
    }
    
    static func restore(completion: @escaping (Bool, String?, Date?)->()) {
        shared.restore { result, errMsg, date in
            debugPrint("static func restore, result=\(result), date=\(date)")

            MVConfigModel.expireDate = date
            
            if MVConfigModel.isVIP() {
                MVDataManager.fetchLocationListWhenUserBecomeVIP()
            }
            completion(result, errMsg, date)
        }
    }
    
    static func purchase(applicationUsername: String = "", productIdentify: String, completion: @escaping (Bool, SKError?, Date?)->()) {
        shared.purchase(productIdentify: productIdentify) { result, err, date in
            debugPrint("static func purchase, result=\(result), date=\(date)")
            
            MVConfigModel.expireDate = date
            
            if MVConfigModel.isVIP() {
                MVDataManager.fetchLocationListWhenUserBecomeVIP()
            }
            debugPrint("MVConfigModel.expireDate = \(MVConfigModel.expireDate)")
            completion(result, err, date)
        }
    }
}
