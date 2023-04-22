import Foundation
import NetworkExtension
import SwiftyJSON

protocol MVVPNToolDelegate {
    func vpnStatusChanged(status: NEVPNStatus)
}

extension NEVPNStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .disconnected: return "Disconnected"
        case .invalid: return "Invalid"
        case .connected: return "Connected"
        case .connecting: return "Connecting"
        case .disconnecting: return "Disconnecting"
        case .reasserting: return "Reasserting"
        @unknown default: return ""
        }
    }
}

public class MVVPNTool {
    var manager: NETunnelProviderManager? = nil
    static let shared = MVVPNTool()
    var delegagte: MVVPNToolDelegate?
    
    @discardableResult
    func cleanVPNProfile() -> Bool {
        self.manager?.removeFromPreferences()
        return self.manager != nil
    }
    
    func isConnected() -> Bool {
        return self.manager?.connection.status == .connected
    }

    public init() {
        saveDefaultConfigIfNeed()
    }
    
    public func DNS1111() {
        NEDNSSettingsManager.shared().loadFromPreferences { loadError in
            if let loadError = loadError {
                debugPrint(loadError)
                return
            }

            let dohDefaultSettings = NEDNSOverHTTPSSettings(servers: [ "1.1.1.1","1.0.0.1","2606:4700:4700::1111","2606:4700:4700::1001" ])
            dohDefaultSettings.serverURL = URL(string: "https://cloudflare-dns.com/dns-query")
            NEDNSSettingsManager.shared().dnsSettings = dohDefaultSettings
            NEDNSSettingsManager.shared().saveToPreferences { saveError in
                if let saveError = saveError {
                    debugPrint(saveError)
                    return
                }
            }
        }
    }

    var authorized = false
    public func hasAuthorization(completion: @escaping (Bool) -> Void) {
        guard authorized == false else { return completion(true) }
        
        NETunnelProviderManager.loadAllFromPreferences() { managers, error in
            guard let managers = managers, error == nil else {
                completion(false)
                return
            }

            if managers.count == 0 {
                completion(false)
            } else {
                self.manager = managers[0]
                self.authorized = true
                completion(true)
            }
        }
    }

    public func loadVPNPreference(completion: @escaping (Error?) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences() { managers, error in
            guard let managers = managers, error == nil else {
                completion(error)
                return
            }

            if managers.count == 0 {
                let newManager = NETunnelProviderManager()
                newManager.protocolConfiguration = NETunnelProviderProtocol()
                newManager.localizedDescription = AppInfo.displayName
                newManager.protocolConfiguration?.serverAddress = AppInfo.displayName
                newManager.saveToPreferences { error in
                    guard error == nil else {
                        completion(error)
                        return
                    }
                    newManager.loadFromPreferences { error in
                        guard error == nil else {
                            completion(error)
                            return
                        }
                        self.manager = newManager
                        completion(nil)
                    }
                }
            } else {
                self.manager = managers[0]
                completion(nil)
            }
        }
    }

    public func enableVPNManager(completion: @escaping (Error?) -> Void) {
        debugPrint("enableVPNManager")
        
        manager?.isEnabled = true
        manager?.saveToPreferences { error in
            guard error == nil else {
                completion(error)
                return
            }
            self.manager?.loadFromPreferences { error in
                completion(error)
            }
        }
    }
    

    public func startConnectVPN(completion: @escaping (Error?) -> Void) {
        do {
            debugPrint("manager.connection.startVPNTunnel")
            if let vt = self.manager {
                self.observeStatus(vt)
            }
            try self.manager?.connection.startVPNTunnel()
        } catch {
            completion(error)
        }
    }
    
    private func test() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            do {
                let session = self.manager?.connection as? NETunnelProviderSession
                try session?.sendProviderMessage(JSONEncoder().encode("message"), responseHandler: { (response) in
                    guard let response = response else {
                        debugPrint("sendProviderMessage nil")
                        return
                    }

                    debugPrint("sendProviderMessage response = ", String(data: response, encoding: .utf8)!)
                })
            } catch let error {
                debugPrint("sendProviderMessage error", error)
            }
        }
    }
    
    func  appGroupMessageLeafReload() {
        do {
            let session = self.manager?.connection as? NETunnelProviderSession
            try session?.sendProviderMessage("reload".data(using: .utf8)!, responseHandler: { (response) in
                guard let response = response else {
                    debugPrint("sendProviderMessage nil")
                    return
                }
                
                debugPrint("sendProviderMessage", JSON(String(data: response, encoding: .utf8)!))
                debugPrint("sendProviderMessage -------------------")
            })
        } catch let error {
            debugPrint("sendProviderMessage error", error)
        }
    }
    
    var observer: NSObjectProtocol?
    private func observeStatus(_ manager: NETunnelProviderManager) {
        if let ob = self.observer {
            NotificationCenter.default.removeObserver(ob)
        }
        self.observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: manager.connection, queue: OperationQueue.main,using: {
            [weak self] notification in
            let connection = notification.object as? NEVPNConnection
            if let status = connection?.status {
                self?.delegagte?.vpnStatusChanged(status: status)
            }
            
            
            switch connection?.status {
                case .none:
                    debugPrint("无")
                
                case .some(.invalid):
                debugPrint("无效")
                
                case .some(.connecting):
                debugPrint("VPN通道连接中")
                
                case .some(.connected):
                debugPrint("VPN通道连接上了")
                
                case .some(.reasserting):
                debugPrint("断言")
                
                case .some(.disconnecting):
                debugPrint("VPN通道断开连接中")
                
                case .some(_):
                debugPrint("其他")
            }
        })
    }
    
    private func stopObservingStatus(_ manager: NETunnelProviderManager) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NEVPNStatusDidChange, object: self.observer)
    }
}

extension MVVPNTool {
    func start(completion: @escaping((_ error: Error?) -> Void)) {
        
        self.loadVPNPreference() { [weak self] error in
            guard error == nil else {
                completion(error)
                //                fatalError("load VPN preference failed: \(error.debugDescription)")
                return
            }
            
            self?.enableVPNManager() { [weak self] error in
                guard error == nil else {
                    completion(error)
                    return
                }
                self?.startConnectVPN() { error in
                    guard error == nil else {
                        completion(error)
                        //                        fatalError("toggle VPN connection failed: \(error.debugDescription)")
                        return
                    }
                }
            }
        }
    }
    
    func stop() {
        self.manager?.connection.stopVPNTunnel()
    }
    
    func updateConfig(proxy: [String], _ autoreload: Bool=true) {
        
        
#if DEBUG
        let conf = """
        [General]
        dns-server = 1.1.1.1, 223.5.5.5
        always-real-ip = apple.com
        tun-fd = REPLACE-ME-WITH-THE-FD
        socks-interface = 127.0.0.1
        socks-port = 1086
        api-interface = 127.0.0.1
        api-port = 1089
        
        [Proxy]
        
        [Proxy Group]
        Tryall = tryall, VMess, Trojan, Trojan1, Trojan2, Trojan3, delay-base=0
        
        [Rule]
        DOMAIN, \(DOMAIN), Direct
        DOMAIN-KEYWORD, flurry, Direct
        DOMAIN-KEYWORD, apple, Direct
        DOMAIN-KEYWORD, appsflyer.com, Direct
        DOMAIN-KEYWORD, ip, Tryall
        EXTERNAL, site:category-ads-all, Reject
        """
        //        EXTERNAL, site:category-ads-all, Reject
        //        EXTERNAL, site:gfw, Tryall
        //        EXTERNAL, mmdb:cn, Direct
        //        EXTERNAL, site:geolocation-cn, Direct
        
        
#else
        let conf = """
        [General]
        dns-server = 1.1.1.1, 223.5.5.5
        always-real-ip = apple.com
        tun-fd = REPLACE-ME-WITH-THE-FD
        socks-interface = 127.0.0.1
        socks-port = 1086
        
        [Proxy]
        
        [Proxy Group]
        Tryall = tryall, VMess, Trojan, Trojan1, Trojan2, Trojan3, delay-base=0
        
        [Rule]
        DOMAIN, \(DOMAIN), Direct
        DOMAIN-KEYWORD, flurry, Direct
        DOMAIN-KEYWORD, apple, Direct
        DOMAIN-KEYWORD, appsflyer.com, Direct
        DOMAIN-KEYWORD, ip, Tryall
        EXTERNAL, site:category-ads-all, Reject
        """
#endif
        
        
        let url = FileManager().containerURL(forSecurityApplicationGroupIdentifier: AppGroup)!.appendingPathComponent("running_config.conf")
        var content = conf
        
        
        #if DEBUG
        let content1 = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
        print("read running_config content = ", JSON(content1))
        #endif
        
        
        var str = "[Proxy]\n"
        str += "Direct = direct" + "\n"
        str += "Reject = reject" + "\n"
        var proxyNames: [String] = []
        for (index, item) in proxy.enumerated() {
            let proxyName = "N\(index)"
            str += "\(proxyName) = " + item + "\n"
            proxyNames.append(proxyName)
        }
        proxyNames.append("Reject")
        let proxyNameString = proxyNames.joined(separator: ",")
        //        #endif
        
        str += "[Proxy Group]\n"
        str += "Tryall = tryall, \(proxyNameString), delay-base=0" + "\n"
        str += "[Rule]"
        
        if CountryCode.isCN_IR {
            str += "\n" + "EXTERNAL, site:gfw, Tryall"
            content += "\n" + "FINAL, Direct"
        } else {
            content += "\n" + "FINAL, Tryall"
        }
        
        let pattern: String = "\\[Proxy\\]((.|\n)*)\\[Rule\\]"
        let regex = try? NSRegularExpression.init(pattern: pattern, options: .caseInsensitive)
        let textRange = NSMakeRange(0, content.count)
        if let newStr = regex?.stringByReplacingMatches(in: content, options: .init(rawValue: 0), range: textRange, withTemplate: str) {
#if DEBUG
            print("newstr = ", JSON(newStr))
#endif
            try? newStr.write(to: url, atomically: false, encoding: .utf8)
        }
        
    }
}

extension MVVPNTool {
    
    private func saveDefaultConfigIfNeed() {

        let conf = """
        [General]
        loglevel = error
        dns-server = 223.5.5.5, 114.114.114.114
        tun-fd = REPLACE-ME-WITH-THE-FD

        [Proxy]

        [Rule]
        FINAL, VMess
        """

        let url = FileManager().containerURL(forSecurityApplicationGroupIdentifier: AppGroup)!.appendingPathComponent("running_config.conf")
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
              try conf.write(to: url, atomically: false, encoding: .utf8)
            } catch {
                debugPrint("fialed to write config file")
            }
        }
    }
    
    //fetchManager not create
    func fetchManager(completion: @escaping((_ error: Error?) -> Void)) {
        
        let fetchClosure = {[weak self] (manager: NETunnelProviderManager?, error: Error?) in
            let openError = error
            guard let manager = manager else {
                completion(openError)
                return
            }
            
            self?.manager = manager
            completion(nil)
        }
        
        // 获取VPN配置
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            guard let vpnManagers = managers else {
                fetchClosure(nil, error)
                return
            }
            
            fetchClosure(vpnManagers.first, NSError())
        }
    }
}
