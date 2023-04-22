//
//  User+current.swift
//
//  Created by Spike on 2019/09/17.
//

import Foundation
import HandyJSON
import AFDateHelper

class MVConfigModel: FileManagerProtocol {
    
    var createdDate = Date().timeIntervalSince1970
    var updateDate = Date().timeIntervalSince1970
    var _expireDate: TimeInterval?
    
    private var isShownPurchaseGuideToday: Bool = false //斐波那契数列
    private var _isShownRateUs: Bool = false
    private var _isShownRateUsCountdown: Int = 5
    private var _isShownRateUsToday: Bool = false
    private var _isShownAgreement: Bool = false
    private var _isCommented: Bool = false
//    var currentNode: LocationModel? = nil
    var currentNode: NodeModel? = nil

    required init() {

    }
        
    func refreshDate() {
        let isInYesterday = Date().dateFor(.startOfDay) > Date(timeIntervalSince1970: updateDate)
        if isInYesterday {
            updateDate = Date().timeIntervalSince1970
            isShownPurchaseGuideToday = false
            _isShownRateUsToday = false
        }
    }
    
    class func fileNameSuffix() -> String? {
        return "config"
    }
    
    class func fileURL() -> URL {
        guard let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            fatalError("Where did Documents go?!")
        }

      let fileName = AppInfo.uniquePrefix + (fileNameSuffix() ?? "")
        let filePath = documentsPath.appendingPathComponent(fileName)
        debugPrint(filePath)

        return URL(fileURLWithPath: filePath)
    }
}

extension MVConfigModel {

    private static let ioQueue = DispatchQueue(label: "xxi" + "ioQueue")
    private static var _current: MVConfigModel?

    static var current: MVConfigModel? {
        set {
            ioQueue.sync {
                _current = newValue
            }
            ioQueue.async {
                if let user = _current {
                    user.saveToFile1()
                } else {
                    deleteFile()
                }
            }
        }

        get {
            /// Not very thread-safe, there may be some data anomalies
            /// but it won't crash, for performance first.
            if let user = _current {
                return user
            }

            ioQueue.sync {
                _current = Self.loadFromFile1()
            }
            
            if _current == nil {
                _current = Self()
            }
            
            return _current
        }
    }
    
    
    class func clearUp() {
        Self.current = nil
    }
}

extension MVConfigModel {
    static var expireDate: Date? {
        get {
            guard let dateTime = current?._expireDate else { return nil }
            return Date(timeIntervalSince1970: dateTime)
        }
        set {
            self.current?._expireDate = newValue?.timeIntervalSince1970
            self.current?.saveToFile1()
        }
    }
    
    static var isExpire: Bool {
        debugPrint("MVConfigModel.isExpire = \(expireDate), current = \(Date())")
        guard let date = expireDate else { return true }
        debugPrint("isExpire = \(date < Date())")
        return date < Date()
    }
    
    static func ensuredVIP() -> Bool {
        guard let date = expireDate else { return true }
        return date.daysSince(Date()) > 4
    }
    
    static func inFreeDays() -> Bool {
        debugPrint("AppInfo.registerDate.adjust(.day, offset: SystemModel.freeDays) = ", AppInfo.registerDate.adjust(.day, offset: SystemModel.freeDays))
        return AppInfo.registerDate.adjust(.day, offset: SystemModel.freeDays) > Date()
    }
    
    static var freeExpireDate: Date? {
        return AppInfo.registerDate.adjust(.day, offset: SystemModel.freeDays)
    }
    
    static func isFreeVIP() -> Bool {
        return inFreeDays()
    }
    
    static func isPremium() -> Bool {
//#if DEBUG
//return true
//#endif
        if SystemModel.isAllowedVIP {
            return true
        }
        return !isExpire
    }
    
    static func isVIP() -> Bool {
//        #if DEBUG
//        return true
//        #endif
        if SystemModel.isAllowedVIP {
            return true
        }
        if inFreeDays() {
            return true
        }
        return !isExpire
    }
    
    static var isShownRateUsToday: Bool {
         get {
            self.current?.refreshDate()
             return self.current?._isShownRateUsToday ?? false
         }
         set {
             self.current?._isShownRateUsToday = newValue
             self.current?.saveToFile1()
         }
     }

    static var shouldShownRateUs: Bool {
        return isShownRateUs == false && isShownRateUsCountdown < 0 ;
    }
    static var isShownRateUs: Bool {
         get {
            self.current?.refreshDate()
             return self.current?._isShownRateUs ?? false
         }
         set {
             self.current?._isShownRateUs = newValue
             self.current?.saveToFile1()
         }
    }
    static var isShownRateUsCountdown: Int {
         get {
             return self.current?._isShownRateUsCountdown ?? 5
         }
         set {
             guard isShownRateUs == false else { return }
             
             self.current?._isShownRateUsCountdown = newValue
             self.current?.saveToFile1()
         }
    }
    
    static var isShownPurchaseGuideToday: Bool {
         get {
            self.current?.refreshDate()
             return self.current?.isShownPurchaseGuideToday ?? false
         }
         set {
             self.current?.isShownPurchaseGuideToday = newValue
             self.current?.saveToFile1()
         }
     }
    static var isShownAgreement: Bool {
        let value = self.current?._isShownAgreement ?? false
        return value
    }
    static func setIsShownAgreement() {
        self.current?._isShownAgreement = true
        self.current?.saveToFile1()
    }
    
    static var isCommented: Bool {
        let value = self.current?._isCommented ?? false
        return value
    }
    static func setIsCommented() {
        self.current?._isCommented = true
        self.current?.saveToFile1()
    }
}

extension MVConfigModel {
    
    class func loadFromFile1() -> MVConfigModel? {
          guard FileManager.default.fileExists(atPath: fileURL().path) else {
              debugPrint("user file not exists")
              return nil
          }

          do {
              let data = try Data(contentsOf: fileURL())
            let user = JSONDeserializer<MVConfigModel>.deserializeFrom(json: String(data: data, encoding: .utf8))
              return user
          } catch {
              debugPrint(error)
          }

        return nil
    }
    
    public func saveToFile1() {
          do {
              let data = toJSONString()?.data(using: .utf8)
            try data?.write(to: MVConfigModel.fileURL())
          } catch {
              debugPrint(error)
          }
    }
}
