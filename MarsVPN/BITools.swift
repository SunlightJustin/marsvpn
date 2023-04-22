//
//  GGTools.swift
//  GOGOVPN
//
//  Created by Justin on 2022/9/26.
//

import Foundation
import SwiftyJSON


//class BITools {
//    static func fetchLocationList(completion: @escaping ([NodeModel]?, Error?)->()) {
//        NetworkBI.shared.request(BIAPI.fetchList) { reuslt in
//            debugPrint(" fetchList = ", reuslt)
//            if case .success(let json) = reuslt {
//                var nodes = [NodeModel]()
//                        
//                if let array = json?.arrayValue {
//                    for item in array {
//                        guard let id = item["id"].int else { continue }
//                        guard let dict = item.dictionaryObject else { continue }
//                        var node = NodeModel()
//                        node.id = id
//                        node.ip = item["ip"].string
//                        node.data = [dict]
//                        nodes.append(node)
//                    }
//
//                }
//                completion(nodes, nil)
//            } else {
//                completion(nil, MVError(code: MVError.Code.unknown, message: "fetch error"))
//            }
//        }
//    }
//
//}
