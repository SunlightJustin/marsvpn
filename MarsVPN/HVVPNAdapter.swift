//
//  GGVPNAdapter.swift
//  GOGOVPN
//
//  Created by Justin on 2022/11/16.
//

import Foundation


//
//class HVVPNAdapter {
//    static var availableVPN: [VPNType] {
////        #if DEBUG
////        return [.Shadowsocks]
////        #endif
//        return HVServerInfoModel.availableVPN
//    }
//    
//    static func whichVPN(node: NodeModel) -> VPNType {
//        guard let contains = node.containVPNTypes() else { return DefaultVPNType }
//        
//        var avaliableArray = availableVPN
//        avaliableArray.append(DefaultVPNType)
//        for avaliable in avaliableArray {
//            if contains.contains(avaliable) {
//                return avaliable
//            }
//        }
//        
//        return contains.first ?? DefaultVPNType
//    }
//}
