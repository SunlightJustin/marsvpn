//
//  LeafViewModel.swift
//  ShadowsocksExtension
//
//  Created by Justin on 2022/7/29.
//

import Foundation
import NetworkExtension
//import Ipify
import Reachability

protocol LXVPNProtocol {
    func connected()
    func disconnected()
}


class MVProxyViewModel {
    
    private var node: NodeModel?
    var delegate: LXVPNProtocol?
    init(_ aDelegate: LXVPNProtocol) {
        self.delegate = aDelegate
        MVVPNTool.shared.delegagte = self        
//        if MVVPNTool.shared.isConnected() {
//            self.delegate?.connected()
//        } else {
//            self.delegate?.disconnected()
//        }
    }
    
    var shouldRestart = false
    var shouldRestartGetNewNodes = false
    func vpnPreferenceAuthorization() {
        MVVPNTool.shared.loadVPNPreference { error in
        }
    }
    
    var startTime = Date()
    func start(completion: @escaping((_ error: Error?) -> Void)) {
//        if MVVPNTool.shared.isConnected() {
//            shouldRestart = true
//            self.stop()
//        } else {
        if  shouldRestart == false {
            shouldRestartGetNewNodes = false
            
            // Set vip befor start tunel
            #if DEBUG
            let isPremiumVIP = MVConfigModel.isPremium()
            MVTunnelStore(appGroup: AppGroup).isPremiumVIP = isPremiumVIP
            if isPremiumVIP == false {
                MVTunnelStore(appGroup: AppGroup).freeDaysFireDate = Date().adjust(.second, offset: 10)
            } else {
                MVTunnelStore(appGroup: AppGroup).freeDaysFireDate = nil
            }
            #else
            let isPremiumVIP = MVConfigModel.isPremium()
            MVTunnelStore(appGroup: AppGroup).isPremiumVIP = isPremiumVIP
            if isPremiumVIP == false {
                MVTunnelStore(appGroup: AppGroup).freeDaysFireDate = MVConfigModel.freeExpireDate
            } else {
                MVTunnelStore(appGroup: AppGroup).freeDaysFireDate = nil
            }
            #endif
            
            startTime = Date()
            MVVPNTool.shared.start { error in
                if let error = error {
                    self.startVPNFailed(error)
                }
            }
        }
    }
    func stop() {
        MVVPNTool.shared.manager?.connection.stopVPNTunnel()
    }
    
    func updateConfig(nodes: [NodeModel], autoreload: Bool=false) {
        node = nodes.first

        guard nodes.count > 0 else {
            MVVPNTool.shared.manager?.connection.stopVPNTunnel()
            return
        }
        
        let random = Int(arc4random()) % nodes.count
        let randomNode = nodes[random]
        node = randomNode
        
        MVConfigModel.current?.currentNode = randomNode
        MVConfigModel.current?.saveToFile1()
        
        let urls: [String] = randomNode.getLeafConfigs()
        MVVPNTool.shared.updateConfig(proxy: urls, autoreload)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            MVConnectionCheck.checkConnectionSocks(selectedNode: randomNode) { result, seconds in
                guard let result = result else { return }
                self.reportConnectStatus(selectedNode: randomNode, result: result, successTime: seconds)
            }
        }
    }
    
    func reportConnectStatus(selectedNode: NodeModel, result: Bool, successTime: Int?) {
        guard let nodeId = selectedNode.id else { return }
        debugPrint("reportConnectStatus: nodeIp = \(selectedNode.ip ?? ""), result = \(result), successTime = \(successTime ?? 0)")
        let vpnType = selectedNode.tempType?.rawValue
        let vpnConfig = selectedNode.tempConfig
        let ping = selectedNode.tempPing
        let host = selectedNode.tempHost

        let countryCode = CountryCode.countryCode ?? "XX"
        let countryPrefix = "ctry_\(countryCode)"
        let nodeName = host?.replacingOccurrences(of: "shoptunnel.site", with: "")
        var eventStr = "NA"
        if let networkStatus = try? Reachability().connection {
            if networkStatus == .cellular, let carrierName = CountryCode.carrierName {
                eventStr = carrierName
            } else {
                eventStr = networkStatus.description
            }
        }
        let carrierCountry = "\(eventStr)_\(CountryCode.countryCode ?? "nocountry")"
        
        var networkType = "NA"
        if let networkStatus = try? Reachability().connection {
            networkType = networkStatus.description
        }

//        HVSingleManager.shared.reportConnectStatus(nodeId: nodeId, status: result ? 1 : 0, localNetwork: networkType, type: vpnType, config: vpnConfig, ping: ping, afterTime: successTime)
        
        //五秒内返回成功的才计入flurry 上报
        var realResult = false
        if let successTime = successTime, result && successTime <= 7 {
            realResult = true
        }
        
        if realResult {
            // 分国家统计连接成功率
            AnalyticsManager.logEvent(countryPrefix + "_connect_1", event1: "time", value: successTime)
            // vip用户连接成功率
            if MVConfigModel.isVIP() {
                AnalyticsManager.logEvent("vip_all_connect_1", event1: "time", value: successTime)
                AnalyticsManager.logEvent("vip_ctry_\(countryCode)_connect_1", event1: "time", value: successTime)
            }
            // 线路连接成功统计
            if let nodeName = nodeName {
//                AnalyticsManager.logEvent("node_\(nodeName)_connect_1", event1: "time", value: successTime)
            }
            // 运营商国家连接成功率
            AnalyticsManager.logEvent("network_\(carrierCountry)_connect_1", event1: "time", value: successTime)
            // 所有连接成功率
            AnalyticsManager.logEvent("all_connect_states_1", event1: "state", value: nodeName)
            
        } else {
            // 分国家统计连接成功率
            AnalyticsManager.logEvent(countryPrefix + "_connect_0", event1: "carrier", value: CountryCode.carrierName)
            // vip用户连接成功率
            if MVConfigModel.isVIP() {
                AnalyticsManager.logEvent("vip_all_connect_0", event1: "time", value: successTime)
                AnalyticsManager.logEvent("vip_ctry_\(countryCode)_connect_0", event1: "time", value: successTime)
            }
            // 线路连接成功统计
            if let nodeName = nodeName {
//                AnalyticsManager.logEvent("node_\(nodeName)_connect_0", event1: "time", value: successTime)
            }
            // 运营商国家连接成功率
            AnalyticsManager.logEvent("network_\(carrierCountry)_connect_0", event1: "time", value: successTime)
            // 所有连接成功率
            AnalyticsManager.logEvent("all_connect_states_0", event1: "state", value: nodeName)
        }
    }
    
    func getDurationTime() -> Double {
        let duration = Date().secondsSince(self.startTime)
        return duration
    }
}

extension MVProxyViewModel {
    func startVPNFailed(_ error: Error) {
        self.delegate?.disconnected()
    }
    
    func vpnAssetedAction() {
        self.delegate?.disconnected()
    }
    
    func vpnConnected() {
        self.delegate?.connected()
    }
    
    func vpnDisconnected() {
        self.delegate?.disconnected()
    }
}

extension MVProxyViewModel: MVVPNToolDelegate {
    func vpnStatusChanged(status: NEVPNStatus) {
        let wha: NEVPNStatus? = status
        switch wha {
            case .none: break
            case .some(.invalid): break
            case .some(.connecting): break
            case .some(.connected):
                self.vpnConnected()
            case .some(.reasserting): break
            case .some(.disconnecting): break
            case .some(_):
                self.vpnDisconnected()
        }
    }
}

extension MVProxyViewModel {
    static func getNetworkIpAddress(_ ipv4Address: String) -> String? {
      var hints = addrinfo(
          ai_flags: AI_DEFAULT,
          ai_family: AF_UNSPEC,
          ai_socktype: SOCK_STREAM,
          ai_protocol: 0,
          ai_addrlen: 0,
          ai_canonname: nil,
          ai_addr: nil,
          ai_next: nil)
      var info: UnsafeMutablePointer<addrinfo>?
      let err = getaddrinfo(ipv4Address, nil, &hints, &info)
      if err != 0 {
          debugPrint("getaddrinfo failed \(String(describing: gai_strerror(err)))")
        return nil
      }
      defer {
        freeaddrinfo(info)
      }
      return getIpAddressString(addr: info?.pointee.ai_addr)
    }

    private static func getIpAddressString(addr: UnsafePointer<sockaddr>?) -> String? {
      guard addr != nil else {
          debugPrint("Failed to get IP address string: invalid argument")
        return nil
      }
      var host : String?
      var buffer = [CChar](repeating: 0, count: Int(NI_MAXHOST))
      let err = getnameinfo(addr, socklen_t(addr!.pointee.sa_len), &buffer, socklen_t(buffer.count),
                            nil, 0, NI_NUMERICHOST | NI_NUMERICSERV)
      if err == 0 {
        host = String(cString: buffer)
      }
      return host
    }
}
