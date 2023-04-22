//
//  SocialConfigure.swift
//  SDM
//
//  Created by clove on 1/14/19.
//  Copyright © 2019 personal.Justin. All rights reserved.
//

import Foundation
import SwiftyStoreKit
import StoreKit
import AFDateHelper
import SwiftyJSON

let payment_sheet_cancelled = "payment_sheet_cancelled"

public class MVIAPManager: NSObject {
    static let shared = MVIAPManager()

    public var applicationUsername: String {
        return ""
    }
    
    var purchasedSubscriptions: Bool?
            
    func hasPurchaseSubscriptions(completion: @escaping (Bool, String?, Date?)->()) {
        let key = AppSpecificSharedSecret
        #if DEBUG
        let appleValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: key)
        #else
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: key)
        #endif
        
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: false) { verifyReceiptResult in
//                debugPrint("verifyReceiptResult = ", verifyReceiptResult)
            switch verifyReceiptResult {
            case .success(let receipt):
                let verifySubscriptionResult = SwiftyStoreKit.verifySubscriptions(productIds: Set(self.productIdentifiers1), inReceipt: receipt)
                switch verifySubscriptionResult {
                case let .purchased(date,_): completion(true, nil, date)
                case let .expired(date,_): completion(false, nil, date)
                case .notPurchased: completion(false, nil, nil)
                }
            case .error(let error):
                completion(false, error.localizedMessage, nil)
            }
        }
    }

    
    public var productIdentifiers: [String]? {
        var array = [String]()
        if productIdentifiers0.count > 0, productIdentifiers1.count > 0 {
            array.append(contentsOf: productIdentifiers0)
            array.append(contentsOf: productIdentifiers1)
        }
        return array.count > 0 ? array : nil
    }
    
    // 1month, 1year
    public var productIdentifiers0: [String] {
        return ["12", "11"]
//        guard let arr =  subscriptionModels0?.filtered({ model in
//            return model.productId != nil && strs.contains(model.productId!)
//        }, map: { $0.productId ?? ""}) else {
//            return [String]()
//        }
//        guard let tel = sortProductIdentifiers(arr, targetSort: strs) else { return [String]() }
//        return tel
    }
    
    // 1month free 3 days
    public var productIdentifiers1: [String] {
        return ["12", "11"]
    }
    
        
    private var _products: [SKProduct]?
    private var _products0: [SKProduct]?
    private var _products1: [SKProduct]?
    private var products: [SKProduct]? {
        get {
            _products = [SKProduct]()
            if let arr = products0 {
                _products?.append(contentsOf: arr)
            }
            if let arr = products1 {
                _products?.append(contentsOf: arr)
            }
            return _products0
        }
        set { _products = newValue }
    }

    public var products0: [SKProduct]? {
        get {
//            guard let prd = _products0, prd.count > 0 else {
//                self.requestProductListFromServer0()
//                return nil
//            }
            return _products0
        }
        set { _products0 = newValue }
    }
    
    public var products1: [SKProduct]? {
        get {
//            guard let prd = _products1, prd.count > 0 else {
//                self.requestProductListFromServer1()
//                return nil
//            }
            return _products1
        }
        set { _products1 = newValue }
    }
    
    // MARK: -
    
    public override init() {
        super.init()
    }
    
    public func purchase(applicationUsername: String = "", productIdentify: String, completion: @escaping (Bool, String?, Date?)->()) {
        SwiftyStoreKit.purchaseProduct(productIdentify, atomically: false, applicationUsername: applicationUsername) { result in
            
            if case .success(let purchase) = result {
                self.purchasedSubscriptions = true  // 标记已经购买
                SwiftyStoreKit.finishTransaction(purchase.transaction)
                self.hasPurchaseSubscriptions(completion: completion)
            } else if case .error(let error) = result {
                var msg: String? = (error as NSError).localizedDescription

                switch error.code {
                case .unknown: msg = "Unknown error. Please contact support"
                case .clientInvalid: msg = "Not allowed to make the payment"
                case .paymentCancelled: msg = payment_sheet_cancelled
                case .paymentInvalid: msg = "The purchase identifier was invalid"
                case .paymentNotAllowed: msg = "The device is not allowed to make the payment"
                case .storeProductNotAvailable: msg = "The product is not available in the current storefront"
                case .cloudServicePermissionDenied: msg = "Access to cloud service information is not allowed"
                case .cloudServiceNetworkConnectionFailed: msg = "Could not connect to the network"
                case .cloudServiceRevoked: msg = "User has revoked permission to use this cloud service"
                default: break
                }

                msg = ((msg?.count ?? 0) > 0) ? msg : "Unknown error is empty."
                debugPrint("error = error = ", type(of: error), error.errorCode, error.errorUserInfo)
                completion(false, msg, nil)
            }
        }
    }
    
    public func purchaseForServer(applicationUsername: String = "", productIdentify: String, completion: @escaping (Data?, String?, SKPaymentTransaction?, PurchaseDetails?, String?)->()) {
        
        SwiftyStoreKit.purchaseProduct(productIdentify, atomically: false, applicationUsername: applicationUsername) { result in
            
            if case .success(let purchase) = result {
                self.purchasedSubscriptions = true  // 标记已经购买
                
                let downloads = purchase.transaction.downloads
                if !downloads.isEmpty {
                    SwiftyStoreKit.start(downloads)
                    
                    SwiftyStoreKit.updatedDownloadsHandler = { skdownloads in
                        let contentURLs = skdownloads.compactMap { $0.contentURL }
                        if contentURLs.count == skdownloads.count {
                            self.didReceivePurchaseDetails() { receiptData, errMsg in
                                completion(receiptData, purchase.productId, purchase.transaction as? SKPaymentTransaction, purchase, errMsg)
                            }
                        }
                    }
                } else {
                    self.didReceivePurchaseDetails() { receiptData, errMsg in
                        completion(receiptData, purchase.productId, purchase.transaction as? SKPaymentTransaction, purchase, errMsg)
                    }
                }
            } else if case .error(let error) = result {
                var msg: String? = (error as NSError).localizedDescription

                switch error.code {
                case .unknown: msg = "Unknown error. Please contact support"
                case .clientInvalid: msg = "Not allowed to make the payment"
                case .paymentCancelled: msg = payment_sheet_cancelled
                case .paymentInvalid: msg = "The purchase identifier was invalid"
                case .paymentNotAllowed: msg = "The device is not allowed to make the payment"
                case .storeProductNotAvailable: msg = "The product is not available in the current storefront"
                case .cloudServicePermissionDenied: msg = "Access to cloud service information is not allowed"
                case .cloudServiceNetworkConnectionFailed: msg = "Could not connect to the network"
                case .cloudServiceRevoked: msg = "User has revoked permission to use this cloud service"
                default: break
                }

                msg = ((msg?.count ?? 0) > 0) ? msg : "Unknown error is empty."
                debugPrint("error = error = ", type(of: error), error.errorCode, error.errorUserInfo)
                completion(nil, nil, nil, nil, msg)
            }
        }
    }
    
    func didReceivePurchaseDetails(forceRefresh: Bool=false, completion: @escaping (Data?, String?)->()) {
        SwiftyStoreKit.fetchReceipt(forceRefresh: forceRefresh) { result in
            if case .success(let receiptData) = result {
                completion(receiptData, nil)
            } else if case .error(let err) = result {
                if err.localizedDescription.contains("ReceiptError error 1") {
                    GGAnalyticsManager.logEvent("ReceiptError_error_1")
                }
//                if let receiptData = SwiftyStoreKit.localReceiptData {
//                    completion(receiptData, nil)
//                } else {
                    completion(nil, err.localizedDescription)
//                }
            }
        }
    }
    
    func restore(completion: @escaping (Bool, String?, Date?)->()) {
        SwiftyStoreKit.restorePurchases(atomically: false) { results in
            if results.restoreFailedPurchases.count > 0 {
                guard let (_, msg) = results.restoreFailedPurchases.first else {
                    return completion(false, "Nothing to Restore", nil)
                }
                
                completion(false, msg, nil)
                debugPrint("Restore Failed: \(results.restoreFailedPurchases)")
            }
            else if results.restoredPurchases.count > 0 {
                self.hasPurchaseSubscriptions(completion: completion)
            } else {
                self.hasPurchaseSubscriptions(completion: completion)
                debugPrint("Nothing to Restore")
            }
        }
    }
    
    func restore1(completion: @escaping (Data?, String?, SKPaymentTransaction?, String?, Bool)->()) {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                guard let (_, msg) = results.restoreFailedPurchases.first else {
                    return completion(nil, nil, nil, "Nothing to Restore", false)
                }
                
                completion(nil, nil, nil, msg, false)
                debugPrint("Restore Failed: \(results.restoreFailedPurchases)")
            }
            else if results.restoredPurchases.count > 0 {
                self.didReceivePurchaseDetails(forceRefresh: true) { receiptData, errMsg in
                    completion(receiptData, nil, nil, errMsg, false)
                }
            } else {
                completion(nil, nil, nil, "Nothing to Restore", false)
                debugPrint("Nothing to Restore")
            }
        }
    }
    
    public func canMakePayments() -> Bool {
        return SwiftyStoreKit.canMakePayments
    }
    
//    public func justPurchasedWithinOneHour(completion: @escaping (Bool) -> Void) {
//        var result = false
//
//        verifyReceipt { verifyReceiptResult in
//
//            switch verifyReceiptResult {
//            case .success(let receipt):
//
//                let purchaseResult = SwiftyStoreKit.verifySubscriptions(
//                    ofType: .nonRenewing(validDuration: 60),
//                    productIds: Set<String>(self.productIdentifiers),
//                    inReceipt: receipt)
//
//                switch purchaseResult {
//                case .purchased(_, let items):
//                    if let receiptItem = items.first {
//                        let purchaseDate = receiptItem.purchaseDate
//                        if Date().since(purchaseDate, in: .minute) < 60 {
//                            result = true
//                        }
//                    }
//                case .expired(_,_): break
//                case .notPurchased: break
//                }
//
//            case .error(_): break
//            }
//
//            completion(result)
//        }
//    }
    
    //MARK: -
    
//    private func requestProductListFromServer0() {
//        SwiftyStoreKit.retrieveProductsInfo(Set(productIdentifiers0)) { result in
//            // RetrieveResults
////            self.products0 = Array(result.retrievedProducts).sorted(by: { (left, right) -> Bool in
////                return left.price.decimalValue < right.price.decimalValue
////            })
//            self.products0 = self.sortRetrieveResults(result.retrievedProducts, serverProductIdentifiers: self.productIdentifiers0)
//
//
////                    for item in self.products! {
////                        let mm = item
////                        debugPrint(mm.price)
////                        debugPrint(mm.productIdentifier)
////                    }
//
//            if let error = result.error {
//                debugPrint(error)
//            }
//        }
//    }
    
//    private func requestProductListFromServer1() {
//        SwiftyStoreKit.retrieveProductsInfo(Set(productIdentifiers1)) { result in
//            // RetrieveResults
////            self.products1 = Array(result.retrievedProducts).sorted(by: { (left, right) -> Bool in
////                return left.price.decimalValue < right.price.decimalValue
////            })
//            self.products1 = self.sortRetrieveResults(result.retrievedProducts, serverProductIdentifiers: self.productIdentifiers1)
//
////                    for item in self.products! {
////                        let mm = item
////                        debugPrint(mm.price)
////                        debugPrint(mm.productIdentifier)
////                    }
//
//            if let error = result.error {
//                debugPrint(error)
//            }
//        }
//    }
    
    private func sortRetrieveResults(_ retrievedProducts: Set<SKProduct>?, serverProductIdentifiers: [String]?) -> [SKProduct]? {
        guard let retrievedProducts = retrievedProducts,
              retrievedProducts.count > 0,
              let serverProductIdentifiers = serverProductIdentifiers else { return nil }
        
            var array = [SKProduct]()
            for item in serverProductIdentifiers {
                for aProduct in retrievedProducts {
                    if item == aProduct.productIdentifier {
                        array.append(aProduct)
                    }
                }
            }

        return array
    }
    
    private func sortProductIdentifiers(_ serverProductIdentifiers: [String]?, targetSort: [String]?) -> [String]? {
        guard let targetSort = targetSort else {
            return serverProductIdentifiers
        }

        guard let serverProductIdentifiers = serverProductIdentifiers,
              serverProductIdentifiers.count > 0 else { return nil }
        
            var array = [String]()
            for item in targetSort {
                for aStr in serverProductIdentifiers {
                    if item == aStr {
                        array.append(aStr)
                    }
                }
            }

        return array
    }
    
//    private func verifyReceipt(completion: @escaping (VerifyReceiptResult) -> Void) {
//        let key = AppSpecificSharedSecret
//
//        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: key)
//        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: true, completion: completion)
//    }
    
    private func product(with productIdentifier:String) -> SKProduct? {
        return products?.filter({ (product) -> Bool in
            product.productIdentifier == productIdentifier
        }).first
    }
    
    // MARK: - Archive
    private func unarchiveProductIdentifiers() -> Dictionary<String,String>? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if paths.count > 0 {
            let path = paths[paths.count - 1]
            let str = path + "/productIdentifier"
            
            return NSKeyedUnarchiver.unarchiveObject(withFile: str) as? Dictionary<String,String>
        }
        
        return nil
    }
    
    private func archiveProductIdentifiers(products: Dictionary<String,String>) {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if paths.count > 0 {
            let path = paths[paths.count - 1]
            let str = path + "/productIdentifier"
            NSKeyedArchiver.archiveRootObject(products, toFile: str)
        }
    }
}

extension MVIAPManager {
     static func setupIAP() {
        
        SwiftyStoreKit.completeTransactions(atomically: false) { purchases in
            debugPrint("SwiftyStoreKit.completeTransactions begin")
            
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    let downloads = purchase.transaction.downloads
                    if !downloads.isEmpty {
                        SwiftyStoreKit.start(downloads)
                    } else if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        debugPrint("purchase.needsFinishTransaction")
                        MVIAPManager.hasPurchaseSubscriptions { _, _, _ in
                            debugPrint("SwiftyStoreKit.completeTransactions = \(purchase.transaction.transactionState.debugDescription): \(purchase.productId)")
                            SwiftyStoreKit.finishTransaction(purchase.transaction)
                        }
//                        MVIAPManager.restorePurchases { (result, errMsg) in
//                            if result {
//                                SwiftyStoreKit.finishTransaction(purchase.transaction)
//                            }
//                        }
                    }
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default: break

                }
            }
        }
        
        SwiftyStoreKit.updatedDownloadsHandler = { downloads in
            // contentURL is not nil if downloadState == .finished
            let contentURLs = downloads.compactMap { $0.contentURL }
            if contentURLs.count == downloads.count {
                debugPrint("SwiftyStoreKit.updatedDownloadsHandler Saving: \(contentURLs)")
//                SwiftyStoreKit.finishTransaction(downloads[0].transaction)
            }
        }
    }
}






extension MVIAPManager {
    
//    private func fetchProductIdentifiers0(completion: @escaping (Bool)->()) {
//        if MVIAPManager.shared.productIdentifiers0.count == 0 {
//            GetSubscriptionFromeServer(recommend:0) { list in
//                if let list = list {
//                    self._subscriptionModels0 = list
//                    completion(true)
//                } else {
//                    completion(false)
//                }
//            }
//        } else {
//            completion(true)
//        }
//    }
    
//    private func fetchProductIdentifiers1(completion: @escaping (Bool)->()) {
//        if MVIAPManager.shared.productIdentifiers1.count == 0 {
//            GetSubscriptionFromeServer(recommend:1) { list in
//                if let list = list {
//                    self._subscriptionModels1 = list
//                    completion(true)
//                } else {
//                    completion(false)
//                }
//            }
//        } else {
//            completion(true)
//        }
//    }

    
    private func fetchProduct1(completion: @escaping (Bool)->()) {
        guard products1.isNilOrEmpty else { return completion(true) }

        if MVIAPManager.shared.productIdentifiers1.count == 0 {
//            GetSubscriptionFromeServer(recommend:1) { list in
//                if let list = list {
//                    self._subscriptionModels1 = list
//
//                    if list.count > 0 {
//                        let set = Set(self.productIdentifiers1)
//                        SwiftyStoreKit.retrieveProductsInfo(set) { result in
//                            // RetrieveResults
////                            self.products1 = Array(result.retrievedProducts).sorted(by: { (left, right) -> Bool in
////                                return left.price.decimalValue < right.price.decimalValue
////                            })
//                            self.products1 = self.sortRetrieveResults(result.retrievedProducts, serverProductIdentifiers: self.productIdentifiers1)
//
//                            if let _ = result.error {
//                                completion(false)
//                            } else {
//                                completion(true)
//                            }
//                        }
//                    } else {
//                        completion(false)
//                    }
//
//
//                } else {
//                    completion(false)
//                }
//            }
        } else {
            SwiftyStoreKit.retrieveProductsInfo(Set(self.productIdentifiers1)) { result in
                // RetrieveResults
//                self.products1 = Array(result.retrievedProducts).sorted(by: { (left, right) -> Bool in
//                    return left.price.decimalValue < right.price.decimalValue
//                })
                self.products1 = self.sortRetrieveResults(result.retrievedProducts, serverProductIdentifiers: self.productIdentifiers1)

                if let _ = result.error {
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    static func fetchProduct1(completion: @escaping (Bool)->()) {
        shared.fetchProduct1 { result in
            completion(result)
            debugPrint("fetchProduct1 = \(result)")
        }
    }
    
    private func fetchProduct0(completion: @escaping (Bool)->()) {
        guard products0.isNilOrEmpty else { return completion(true) }
        
        if MVIAPManager.shared.productIdentifiers0.count == 0 {
//            GetSubscriptionFromeServer(recommend:0) { list in
//                if let list = list {
//                    self._subscriptionModels0 = list
//
//                    if list.count > 0 {
//                        let set = Set(self.productIdentifiers0)
//                        SwiftyStoreKit.retrieveProductsInfo(set) { result in
//                            // RetrieveResults
////                            self.products0 = Array(result.retrievedProducts).sorted(by: { (left, right) -> Bool in
////                                return left.price.decimalValue < right.price.decimalValue
////                            })
//                            self.products0 = self.sortRetrieveResults(result.retrievedProducts, serverProductIdentifiers: self.productIdentifiers0)
//
//                            if let _ = result.error {
//                                completion(false)
//                            } else {
//                                completion(true)
//                            }
//                        }
//                    } else {
//                        completion(false)
//                    }
//
//
//                } else {
//                    completion(false)
//                }
//            }
        } else {
            SwiftyStoreKit.retrieveProductsInfo(Set(self.productIdentifiers0)) { result in
                // RetrieveResults
//                self.products0 = Array(result.retrievedProducts).sorted(by: { (left, right) -> Bool in
//                    return left.price.decimalValue < right.price.decimalValue
//                })
                self.products0 = self.sortRetrieveResults(result.retrievedProducts, serverProductIdentifiers: self.productIdentifiers0)

                if let _ = result.error {
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    static func fetchProduct0(completion: @escaping (Bool)->()) {
        shared.fetchProduct0(completion: completion)
    }
}


