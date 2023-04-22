// Copyright 2018 The Outline Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

// Persistence layer for a single |OutlineTunnel| object.
@objcMembers
class GGTunnelStore: NSObject {
  // TODO(alalama): s/connection/tunnel when we update the schema.
    private static let kTunnelStoreKey = "connectionStore"
  private static let kTunnelStatusKey = "connectionStatus"
    private static let kUdpSupportKey = "udpSupport"
    private static let kWireGuardKey = "kWireGuardKey"
    private static let kAvalableTimeKey = "kAvalableTimeKey"
    private static let kStartTimeKey = "kStartTimeKey"
    private static let kFreeDaysFireDateKey = "kFreeDaysFireDateKey"
    private static let kIsVIPKey = "kIsVIPKey"

  private let defaults: UserDefaults?

  // Constructs the store with UserDefaults as the storage.
  required init(appGroup: String) {
    defaults = UserDefaults(suiteName: appGroup)
    super.init()
  }

  // Loads a previously saved tunnel from the store.
//  func load() -> OutlineTunnel? {
//    if let encodedTunnel = defaults?.data(forKey: GGTunnelStore.kTunnelStoreKey) {
//      return OutlineTunnel.decode(encodedTunnel)
//    }
//    return nil
//  }

//  // Writes |tunnel| to the store.
//  @discardableResult
//  func save(_ tunnel: OutlineTunnel) -> Bool {
//    if let encodedTunnel = tunnel.encode() {
//      defaults?.set(encodedTunnel, forKey: GGTunnelStore.kTunnelStoreKey)
//    }
//    return true
//  }
//
//  var status: OutlineTunnel.TunnelStatus {
//    get {
//      let status = defaults?.integer(forKey: GGTunnelStore.kTunnelStatusKey)
//          ?? OutlineTunnel.TunnelStatus.disconnected.rawValue
//      return OutlineTunnel.TunnelStatus(rawValue:status)
//          ?? OutlineTunnel.TunnelStatus.disconnected
//    }
//    set(newStatus) {
//      defaults?.set(newStatus.rawValue, forKey: GGTunnelStore.kTunnelStatusKey)
//    }
//  }

  var isUdpSupported: Bool {
    get {
      return defaults?.bool(forKey: GGTunnelStore.kUdpSupportKey) ?? false
    }
    set(udpSupport) {
      defaults?.set(udpSupport, forKey: GGTunnelStore.kUdpSupportKey)
    }
  }
    
  var isWireGuard: Bool {
      get {
        return defaults?.bool(forKey: GGTunnelStore.kWireGuardKey) ?? false
      }
      set(udpSupport) {
        defaults?.set(udpSupport, forKey: GGTunnelStore.kWireGuardKey)
      }
  }
    
  var isPremiumVIP: Bool {
      get {
        return defaults?.bool(forKey: GGTunnelStore.kIsVIPKey) ?? false
      }
      set(udpSupport) {
        defaults?.set(udpSupport, forKey: GGTunnelStore.kIsVIPKey)
      }
  }
    
//  var avalableTime: Int? {
//      get {
//        return defaults?.integer(forKey: GGTunnelStore.kAvalableTimeKey)
//      }
//      set(date) {
//        defaults?.set(date, forKey: GGTunnelStore.kAvalableTimeKey)
//      }
//  }
    
    var freeDaysFireDate: Date? {
        get {
            guard let timeInterval = defaults?.double(forKey: GGTunnelStore.kFreeDaysFireDateKey), timeInterval > 0.1 else { return nil }
            return Date(timeIntervalSince1970: timeInterval)
        }
        set(date) {
//            wg_log(.info, message: "var kFreeDaysFireDateKey: Date? { = \(date)")

            if let date = date {
                defaults?.set(date.timeIntervalSince1970, forKey: GGTunnelStore.kFreeDaysFireDateKey)
            } else {
                defaults?.removeObject(forKey: GGTunnelStore.kFreeDaysFireDateKey)
            }
        }
    }

    
    // startTime be recorded at startTunnel begin
    var startTime: Date? {
        get {
            guard let timeInterval = defaults?.double(forKey: GGTunnelStore.kStartTimeKey), timeInterval > 0.1 else { return nil }
            return Date(timeIntervalSince1970: timeInterval)
        }
        set(date) {
//            wg_log(.info, message: "var startTime: Date? { = \(date)")

            if let date = date {
//                wg_log(.info, message: "var startTime: let date = date = \(date)")
                defaults?.set(date.timeIntervalSince1970, forKey: GGTunnelStore.kStartTimeKey)
            } else {
//                wg_log(.info, message: "var startTime: remove")
                defaults?.removeObject(forKey: GGTunnelStore.kStartTimeKey)
//                let timeInterval = defaults?.double(forKey: GGTunnelStore.kStartTimeKey)
//                wg_log(.info, message: "defaults?.double(forKey: GGTunnelStore.kStartTimeKey = \(timeInterval), date = \(Date(timeIntervalSince1970: timeInterval ?? 0))")
//                if let timeInterval = timeInterval {
//                    debugPrint("ahahah")
//                }
            }
        }
    }
    
//    static var realRemainderTime: Int {
//        let group = GGTunnelStore(appGroup: AppGroup)
//        wg_log(.info, message: "realRemainderTime , startTime = \(group.startTime)")
//
//        guard let avalableTime = group.avalableTime else { return 0 }
//        guard let startTime = group.startTime else { return avalableTime }
//        
//        let usedThisTime = Int(Date().timeIntervalSince1970 - startTime.timeIntervalSince1970)
//        let result = avalableTime - usedThisTime
//        
//        wg_log(.info, message: "realRemainderTime = \(result), avalableTime = \(avalableTime), usedThisTime = \(usedThisTime)")
//
//        return result > 0 ? result : 0
//    }
    
    static func updateAvailableTimeWhenStopTunel() {
        let group = GGTunnelStore(appGroup: AppGroup)
//        group.avalableTime = realRemainderTime
        group.startTime = nil
    }

}

