//
//  LocationModel.swift
//  GOGOVPN
//
//  Created by Justin on 2022/6/27.
//

import Foundation
import HandyJSON

public final class SystemModel: FileManagerProtocol {
    var allow_region: [String]?
    var allow_vip_short_uid: [String]?
    var free_days: Int = 0
    var disable_cache_node: Bool = false

    
    required public init() {}
}

extension SystemModel {
    
    static var isAllowedRegion: Bool {
        guard CountryCode.isCN_IR else { return true }
        
        if let array = SystemModel.current?.allow_vip_short_uid, array.contains(AppInfo.shortDeviceId) {
            return true
        }
        
        if let array = SystemModel.current?.allow_region, let country = CountryCode.countryCode, array.contains(country) {
            return true
        }

        return false
    }
    
    static var freeDays: Int {
        return SystemModel.current?.free_days ?? 0
    }
    
    static var isAllowedVIP: Bool {
        if let array = SystemModel.current?.allow_vip_short_uid, array.contains(AppInfo.shortDeviceId) {
            return true
        }
        return false
    }
}


extension SystemModel {
    private static let ioQueue = DispatchQueue(label: "uiew" + "ioQueue")
    private static var _current: SystemModel?

    static var current: SystemModel? {
        set {
            ioQueue.sync {
                _current = newValue
            }
            ioQueue.async {
                if let user = _current {
                    user.saveToFile()
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
                _current = Self.loadFromFile()
            }

            if _current == nil {
                _current = Self()
            }

            return _current
        }
    }
    
    
    public static func saveToFile() {
        SystemModel.current?.saveToFile()
    }

    
//    class func clearUp() {
//        Self.current = nil
//    }
    
//    class func loadFromFile1() -> SystemModel? {
//          guard FileManager.default.fileExists(atPath: fileURL().path) else {
//              debugPrint("user file not exists")
//              return nil
//          }
//
//          do {
//              let data = try Data(contentsOf: fileURL())
//            let user = JSONDeserializer<Self>.deserializeFrom(json: String(data: data, encoding: .utf8))
//              return user
//          } catch {
//              debugPrint(error)
//          }
//
//        return nil
//    }
//
//    public func saveToFile1() {
//          do {
//              let data = toJSONString()?.data(using: .utf8)
//            try data?.write(to: MVConfigModel.fileURL())
//          } catch {
//              debugPrint(error)
//          }
//      }
}
