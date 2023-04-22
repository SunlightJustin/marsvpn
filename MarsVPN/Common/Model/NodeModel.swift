//
//  LocationModel.swift
//  GOGOVPN
//
//  Created by Justin on 2022/6/27.
//

import Foundation
import HandyJSON
import SwiftyJSON
import HDPingTools

let DefaultVPNType = VPNType.Trojan

enum VPNType: String, HandyJSONEnum {
    case Auto
    case Shadowsocks
    case VMess
    case Trojan
    case WireGuard
    
    static var all: [VPNType] {
        return [.Shadowsocks, .VMess, .Trojan, .WireGuard]
    }
}

public final class NodeModel: HandyJSON, Equatable {
    
    var id: Int?
    var ip: String?
    var free: Int?

    var data: Array<Dictionary<String, Any>>?

    // for report
    var tempConfig: String?
    var tempType: VPNType?
    var tempPing: String?
    var tempHost: String?

    
    var locationId: Int?
    var name: String?
    var type: Int?          //1免费，2付费
//    var children: LocationModel?
    var port: String?
    var domain: String?
    var password: String?
    var encryption: String?
    var `protocol`: VPNType?
    var alive: Int?
    var status: Int?
    var connections: Int?
    var url: String?
    var security: String?   //tls in it
    var transfer: String?   //ws in it
    var path: String?   //ws-path
    var image: String?
    var country: String?
    var city: String?
    var country_code: String?

    var remark: String? {
        return ""
    }
    
    var isFree: Bool {
        return free == 1
    }
    
    func displayName() -> String? {
        return name
    }
    
    func flagImage() -> UIImage? {
        guard let code = country_code?.lowercased() else { return nil }
        return UIImage(named: "flag_\(code)")
    }

    required public init() { }
    
    public func mapping(mapper: HelpingMapper) {
        mapper <<<
            `protocol` <-- ("protocol", EnumTransform<VPNType>())
    }

    public static func == (lhs: NodeModel, rhs: NodeModel) -> Bool {
        return lhs.id == rhs.id
    }
}

// factory
extension NodeModel {
    
    private func hasCloudflare() -> Bool {
        return false
//        guard let array = HVServerInfoModel.ipLists(), array.isEmpty == false else { return false }
//        return true
    }
}

extension NodeModel {

    static func parseDictionary(_ array: Array<Dictionary<String, Any>>, id: Int?=nil, ip: String?=nil) -> NodeModel {
        let node = NodeModel()
        node.id = id
        node.ip = ip
        node.data = array
        return node
    }
    
    private func parseLeafVMessConfig(_ json: JSON, ip: String?=nil) -> String? {
        guard let host = json["add"].string else { return nil}
        guard let port = json["port"].string else { return nil}
        guard let password = json["id"].string else { return nil}
        tempHost = host

        var str = "vmess"
        str += ", " + (ip ?? host)
        str += ", " + port
        str += ", " + "username=" + password
        
        if let ws = json["net"].string, ws == "ws" {
            str += ", " + "ws=true"
            if let path = json["path"].string {
                str += ", " + "ws-path=" + path
            }
            if let ws_host = json["host"].string {
                str += ", " + "ws-host=" + ws_host
                str += ", " + "sni=" + ws_host
            }
        }
        if let tls = json["tls"].string, tls == "tls" {
            str += ", " + "tls=true"
        }
        
        return str
    }
    
    private func parseLeafTrojanConfig(_ json: JSON, ip: String?=nil) -> String? {
        guard let host = json["address"].string else { return nil}
        guard let port = json["port"].string else { return nil}
        guard let password = json["password"].string else { return nil}
        tempHost = host
                
        var str = "trojan"
        str += ", " + (ip ?? host)
        str += ", " + port
        str += ", " + "password=" + password
        
        if let ws = json["network"].string, ws == "ws" {
            str += ", " + "ws=true"
            if let path = json["path"].string {
                str += ", " + "ws-path=" + path
            }
            if let ws_host = json["host"].string {
                str += ", " + "ws-host=" + ws_host
                str += ", " + "sni=" + ws_host
            }
        }
        if let tls = json["tls"].string, tls == "tls" {
            str += ", " + "tls=true"
        }
        
        return str
    }
    
    private func parseLeafShadowsocksConfig(_ json: JSON) -> String? {
        guard let host = json["address"].string else { return nil}
        guard let port = json["port"].string else { return nil}
        guard let password = json["password"].string else { return nil}
        guard let encryptmethod = json["encryptmethod"].string else { return nil}
        tempHost = host
  
        var str = "ss"
        str += ", " + host
        str += ", " + port
        str += ", " + "password=" + password
        str += ", " + "encrypt-method=" + encryptmethod
        
        return str
    }

    private func getJSONProxies(_ type: VPNType) -> [JSON]? {
        guard let data = data else { return nil }
        for dict in data {
            if let typeStr = dict["type"] as? String{
                switch type {
                case .Shadowsocks:
                    if typeStr.lowercased() == type.rawValue.lowercased() {
                        return [JSON(dict)]
                    }
                case .VMess:
                    if typeStr.lowercased() == type.rawValue.lowercased() {
                        return [JSON(dict)]
                    }
                case .Trojan, .Auto:
                    if typeStr.lowercased() == type.rawValue.lowercased() {
                        return [JSON(dict)]
                    }
                case .WireGuard:
                    if typeStr.lowercased() == type.rawValue.lowercased() {
                        return [JSON(dict)]
//                        return JSON(parseJSON: value)["proxies"].arrayValue
                    }
                }
            }
        }
        
        return nil
    }
    
    func containVPNTypes() -> [VPNType]? {
        guard let data = data else { return nil }
        var array = [VPNType]()
        for dict in data {
            if let typeStr = dict["type"] as? String {
                let allTypes:[VPNType] = [.Auto, .WireGuard, .Shadowsocks, .VMess, .Trojan]
                for type in allTypes {
                    if typeStr.lowercased() == type.rawValue.lowercased() {
                        array.append(type)
                    }
                }
            }
        }
        
        debugPrint("containVPNTypes = \(array)")
        
        return array
    }
    
    private func getLeafVmessConfigs() -> [String] {
        var array = [String]()
        if let jsons = getJSONProxies(.VMess) {
            for json in jsons {
                // ws + cloudflareIP
                if let ws = json["net"].string, ws == "ws", hasCloudflare() {
//                    if let ipList = HVServerInfoModel.ipLists() {
//                        for ip in ipList {
//                            if let str = parseLeafVMessConfig(json, ip: ip) {
//                                array.append(str)
//                            }
//                        }
//                    }
                } else {
                    if let str = parseLeafVMessConfig(json) {
                        array.append(str)
                    }
                }
            }
        }
        
        return array
    }
    
    private func getLeafTrojanConfigs() -> [String] {
        var array = [String]()
        if let jsons = getJSONProxies(.Trojan) {
            for json in jsons {
                // ws + cloudflareIP
                if let ws = json["network"].string, ws == "ws", hasCloudflare() {
//                    if let ipList = HVServerInfoModel.ipLists() {
//                        for ip in ipList {
//                            if let str = parseLeafTrojanConfig(json, ip: ip) {
//                                array.append(str)
//                            }
//                        }
//                    }
                } else {
                    if let str = parseLeafTrojanConfig(json) {
                        array.append(str)
                    }
                }
            }
        }
        
        return array
    }
    
    private func getLeafShadowsocksConfigs() -> [String] {
        var array = [String]()
        if let jsons = getJSONProxies(.Shadowsocks) {
            for json in jsons {
                if let str = parseLeafShadowsocksConfig(json) {
                    array.append(str)
                }
            }
        }
        return array
    }
    
    func getWireGuardConfigs() -> [[String:String]] {
        tempType = .WireGuard
        tempConfig = nil
        
        //ping this server ip
        pingTools()
        
        var array = [[String:String]]()
        if let jsons = getJSONProxies(.WireGuard) {
            tempConfig = jsons.first?.rawString()
            
            for json in jsons {
                var dict = [String:String]()
                if let str = json["PublicKey"].string {
                    dict["PublicKey"] = str
                }
                if let str = json["PrivateKey"].string {
                    dict["PrivateKey"] = str
                }
                if let str = json["PresharedKey"].string {
                    dict["PresharedKey"] = str
                }
                
                if let endPoint = json["Endpoint"].string {
                    dict["Endpoint"] = endPoint

//                    let split = endPoint.splitToArray(separator: ":")
//                    if split.count == 2 {
//                        dict["Address"] = split[0]
//                        dict["Port"] = split[1]
//                        tempHost = split[0]
//                    }
                }
                
                array.append(dict)
            }
        }
        
        return array
    }
    
    func getLeafConfigs() -> [String] {
        tempType = nil
        tempConfig = nil
        tempHost = nil

        var strings = [String]()
        var containsVPN = [String]()

        //ping this server ip
        pingTools()
        
        
        var typeArray = [VPNType]()
//        let availableVPN = HVVPNAdapter.availableVPN
        let availableVPN = VPNType.all
        for type in VPNType.all {
            var array = [String]()

            switch type {
            case .Auto: break
            case .Shadowsocks:
                array = getLeafShadowsocksConfigs()
            case .VMess:
                array = getLeafVmessConfigs()
            case .Trojan:
                array = getLeafTrojanConfigs()
            case .WireGuard: break
            }
            
            if array.count > 0 {
                containsVPN.append(contentsOf: array)

                if availableVPN.contains(type) {
                    strings.append(contentsOf: array)
                    typeArray.append(type)
                }
            }
        }
        
        let result = strings.count > 0 ? strings : containsVPN
        
        let str = result.first
        tempConfig = str
        tempType = typeArray.count > 1 ? .Auto : typeArray.first
        if strings.count == 0 {
            tempType = .Auto
        }
        
        return result
    }
    
    
    func pingTools() {
        tempPing = nil
        
        let pingTools = HDPingTools(hostName: ip)
        pingTools.showNetworkActivityIndicator = .none
        pingTools.start(pingType: .any, interval: .second(2)) { [weak self] (response, error) in
            debugPrint("ping response = \(response)")
//            if let error = error {
//                print(error)
//            }
            
            if let response = response {
                let second = response.responseTime.second
                let milSecond = second * 1000
                let mm: Int = Int(milSecond)
                self?.tempPing = mm.string
            }
            
            pingTools.stop()
        }
    }
    

   

}
