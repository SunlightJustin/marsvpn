//
//  MVConnectionCheck.swift
//  GOGOVPN
//
//  Created by Justin on 2022/11/19.
//

import Foundation

class MVConnectionCheck {
    
    //  (Bool?, Int?), bool是否成功或者没发生， int 多少秒返回
    static func checkConnectionSocks(selectedNode: NodeModel, completion: @escaping (Bool?, Int?)->() )  {
        guard validNodeStill(selectedNode: selectedNode) else { return completion(nil, nil) }
        
        // 3秒前启动
        let startTime = Date().adding(.second, value: -3)
        
        // first time
        sockConnectCheck(selectedNode, timeout: 5) { result in
            guard let result = result else { return completion(nil, secondsAfter(startTime)) }
            guard result == false else { return completion(true, secondsAfter(startTime)) }

            // second time after 5s
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                sockConnectCheck(selectedNode, timeout: 10) { result in
                    guard let result = result else { return completion(nil, secondsAfter(startTime)) }
                    guard result == false else { return completion(true, secondsAfter(startTime)) }

                    // third time after 5s
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        sockConnectCheck(selectedNode, timeout: 10) { result in
                            guard let result = result else { return completion(nil, secondsAfter(startTime)) }
                            guard result == false else { return completion(true, secondsAfter(startTime)) }

                            completion(false, secondsAfter(startTime))
                        }
                    }
                }
            }
        }
    }
    
    //  (Bool?, Int?), bool是否成功或者没发生， int 多少秒返回
    static func checkConnectionIP(selectedNode: NodeModel, completion: @escaping (Bool?, Int?)->() )  {
        guard validNodeStill(selectedNode: selectedNode) else { return completion(nil, nil) }
        
        // 3秒前启动
        let startTime = Date().adding(.second, value: -3)

        // first time
        ipConnectCheck(selectedNode, timeout: 5) { result in
            guard let result = result else { return completion(nil, secondsAfter(startTime)) }
            guard result == false else { return completion(true, secondsAfter(startTime)) }

            // second time after 5s
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                ipConnectCheck(selectedNode, timeout: 10) { result in
                    guard let result = result else { return completion(nil, secondsAfter(startTime)) }
                    guard result == false else { return completion(true, secondsAfter(startTime)) }

                    // third time after 5s
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        ipConnectCheck(selectedNode, timeout: 10) { result in
                            guard let result = result else { return completion(nil, secondsAfter(startTime)) }
                            guard result == false else { return completion(true, secondsAfter(startTime)) }

                            completion(false, secondsAfter(startTime))
                        }
                    }
                }
            }
        }
    }
    
    static func sockConnectCheck(_ selectedNode: NodeModel, timeout: TimeInterval=5, completion: @escaping (Bool?)->() )  {
        guard validNodeStill(selectedNode: selectedNode) else { return completion(nil) }
        
        Ipify.checkGoogleWithProxy(host: "127.0.0.1", port: 1086, timeout: timeout) { result in
            guard validNodeStill(selectedNode: selectedNode) else { return completion(nil) }

            switch result {
            case .success:
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
    
    private static func validNodeStill(selectedNode: NodeModel) -> Bool {
        // node is not empty
        guard let current = MVConfigModel.current?.currentNode else { return false }
        // node exist still
        guard selectedNode.id == current.id else { return false }
        // vpn connected confirm
        guard MVVPNTool.shared.isConnected() else { return false }
        return true
    }
    
    static func ipConnectCheck(_ selectedNode: NodeModel, timeout: TimeInterval=5, completion: @escaping (Bool?)->() )  {
        guard validNodeStill(selectedNode: selectedNode) else { return completion(nil) }
        guard let ip = selectedNode.ip else { return completion(nil) }

        Ipify.getPublicIPAddress() { result in
            guard validNodeStill(selectedNode: selectedNode) else { return completion(nil) }

            switch result {
            case .success(let iphoneIp): completion(ip == iphoneIp)
            case .failure: completion(false)
            }
        }
    }
    
    
    private static func secondsAfter(_ date: Date) -> Int {
        return Int(Date().timeIntervalSince1970 - date.timeIntervalSince1970)
    }

}
