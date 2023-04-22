import NetworkExtension

let appGroup = AppGroup

let leafId: UInt16 = 7

//let conf = """
//[General]
//loglevel = error
//dns-server = 223.5.5.5, 114.114.114.114
//tun-fd = REPLACE-ME-WITH-THE-FD
//
//[Proxy]
//Direct = direct
//VMess = vmess, GB-47-143.gogoviodes.xyz, 21008, username=bf5b787f-56a7-482c-9f64-6670edc5a0f6
//"""


//let conf1 = """
//[General]
//dns-server = 223.5.5.5
//interface = 127.0.0.1
//port = 1087
//
//socks-interface = 127.0.0.1
//socks-port = 1086
//
//[Proxy]
//Direct = direct
//Trojan = trojan, cn201.03download.xyz, 22012, password=efc2a93e-8412-49a7-a43e-00e4dd64e6af
//
//"""

//VMess = vmess, GB-47-143.gogoviodes.xyz, 21008, username=bf5b787f-56a7-482c-9f64-6670edc5a0f6
//Trojan = trojan, cn201.03download.xyz, 22012, password=efc2a93e-8412-49a7-a43e-00e4dd64e6af
//Trojan = trojan, RO-25-81.gogoviodes.xyz, 443, password=5c90eabc1bb5gogovpn

//socks-interface = 127.0.0.1
//socks-port = 1086

let conf = """
[General]
loglevel = error
dns-server = 223.5.5.5, 114.114.114.114
tun-fd = REPLACE-ME-WITH-THE-FD

[Proxy]

[Rule]
FINAL, VMess
"""

class PacketTunnelProvider: NEPacketTunnelProvider {

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        
        let tunnelNetworkSettings = createTunnelSettings()
        setTunnelNetworkSettings(tunnelNetworkSettings) { [weak self] error in
            self?.leafConnect()
            completionHandler(nil)
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        leaf_shutdown(leafId)
        // Add code here to start the process of stopping the tunnel.
        completionHandler()
    }
   
    func leafConnect() {
        let url = FileManager().containerURL(forSecurityApplicationGroupIdentifier: appGroup)!.appendingPathComponent("running_config.conf")
        var str1 = try? String(contentsOf: url, encoding: .utf8)
        
        
        //Repalace geosite path
        if let url = Bundle.main.url(forResource: "geosite", withExtension: "dat") {
            str1 = str1?.replacingOccurrences(of: "site:category-ads-all", with:"site:\(url.path):category-ads-all")
            str1 = str1?.replacingOccurrences(of: "site:gfw", with:"site:\(url.path):gfw")
        }
        
        //Replace tunfd
        let content = str1 ?? conf
        let tunFd = self.getSocket()
        let target = "tun-fd = \(tunFd!)"
        let pattern: String = "tun-fd =.*"
        let regex = try? NSRegularExpression.init(pattern: pattern, options: .caseInsensitive)
        let textRange = NSMakeRange(0, content.count)
        let confWithFd = (regex?.stringByReplacingMatches(in: content, options: .init(rawValue: 0), range: textRange, withTemplate: target))!
        try? confWithFd.write(to: url, atomically: false, encoding: .utf8)
        
        
        var certPath = Bundle.main.executableURL?.deletingLastPathComponent()
        setenv("SSL_CERT_DIR", certPath?.path, 1)
        certPath?.appendPathComponent("cacert.pem")
        setenv("SSL_CERT_FILE", certPath?.path, 1)

        DispatchQueue.global(qos: .userInteractive).async {
            signal(SIGPIPE, SIG_IGN)
            leaf_run(leafId, String(url.path))
        }
    }
    
    func getSocket() -> Int32? {
        if #available(iOS 15, *) {
            var buf = [CChar](repeating: 0, count: Int(IFNAMSIZ))
            let utunPrefix = "utun".utf8CString.dropLast()
            return (0...1024).first { (_ fd: Int32) -> Bool in
                var len = socklen_t(buf.count)
                return getsockopt(fd, 2, 2, &buf, &len) == 0 && buf.starts(with: utunPrefix)
            }
        } else {
            return self.packetFlow.value(forKeyPath: "socket.fileDescriptor") as? Int32
        }
    }
    
    var aha: ((Data?) -> Void)?
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
//        aha = completionHandler
        
        // Add code here to handle the message.
        if let handler = completionHandler {
            if let str = String(data: messageData, encoding: .utf8) {
//                handler(messageData)
                if str == "reload" {
//                    let result = leaf_reload(leafId)
//                    leaf_shutdown(leafId)
//                    self.leafConnect()
                    let url = FileManager().containerURL(forSecurityApplicationGroupIdentifier: AppGroup)!.appendingPathComponent("running_config.conf")
                    let content = (try? String(contentsOf: url, encoding: .utf8)) ?? "nil"
//                    let message = content + "\n\(result)"
                    let message = content + "\n\(0)"
                    handler(message.data(using: .utf8))
                }
            }
        }
    }

    override func sleep(completionHandler: @escaping () -> Void) {
        // Add code here to get ready to sleep.
        completionHandler()
    }

    override func wake() {
        // Add code here to wake up.
    }

    func createTunnelSettings() -> NEPacketTunnelNetworkSettings  {
        let newSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "240.0.0.10")
        newSettings.ipv4Settings = NEIPv4Settings(addresses: ["240.0.0.1"], subnetMasks: ["255.255.255.0"])
        newSettings.ipv4Settings?.includedRoutes = [NEIPv4Route.`default`()]
        newSettings.proxySettings = nil
        newSettings.dnsSettings = NEDNSSettings(servers: ["223.5.5.5", "8.8.8.8"])
        newSettings.mtu = 1500
        return newSettings
    }
}




