//
//  MVDataManager.swift
//  MarsVPN
//
//  Created by Justin on 2022/12/1.
//

import Foundation
//import FirebaseFirestore
import HandyJSON

fileprivate let LinesCollectionName = "lines"

class MVDataManager {
    static let shared = MVDataManager()
    var locationList = [NodeModel]()
    
    static func fetchLocationList(completion: @escaping ([NodeModel]?, Error?)->()) {
        NetworkBI.shared.request(BIAPI.fetchList) { reuslt in
            debugPrint(" fetchList = ", reuslt)
            if case .success(let json) = reuslt {
                var nodes = [NodeModel]()
                        
                if let array = json?.arrayValue {
                    for item in array {
                        guard let id = item["id"].int else { continue }
                        guard let dict = item.dictionaryObject else { continue }
                        var node = NodeModel()
                        node.id = id
                        node.ip = item["ip"].string
                        node.name = item["name"].string
                        node.city = item["city"].string
                        node.country = item["country"].string
                        node.country_code = item["country_code"].string
                        node.free = item["free"].int
//                        node.remark = item["remark"].string
                        node.data = [dict]
                        nodes.append(node)
                    }

                }
                shared.locationList = nodes
                completion(nodes, nil)
            } else {
                completion(nil, MVError(code: MVError.Code.unknown, message: "fetch error"))
            }
        }
    }

    
//    static func fetchLocationList(completion: @escaping ([LocationModel]?, Error?)->()) {
//        let collectionRef = Firestore.firestore().collection(LinesCollectionName)
//        collectionRef.order(by: "order").getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                debugPrint("Error getting documents: \(err)")
//                completion(nil, err)
//            } else {
//
//                guard let documents = querySnapshot?.documents else {
//                    debugPrint("empty getting documents")
//                    completion(nil, MVError(code: .unknown, message: "Empty data"))
//                    return
//                }
//
//                var array = [LocationModel]()
//                for document in documents {
//                    if let model = LocationModel.deserialize(from: document.data()) {
//                        array.append(model)
//                    }
//                }
//
//                // default value
//                if MVConfigModel.current?.currentNode == nil {
//                    MVConfigModel.current?.currentNode = array.first
//                }
//
//                // save location
//                shared.locationList = array
//                completion(array, nil)
//            }
//        }
//    }
    
//    var startFetchingList = false
    static func fetchLocationListWhenAppLauching() {
        fetchLocationList { nodeList, err in
            
        }
    }
    
    static func fetchLocationListWhenUserBecomeVIP() {
        fetchLocationListWhenAppLauching()
    }
    
//    static func fetchNode(_ server: String, completion: @escaping ( NodeModel?, Error?)->()) {
//        if let model = NodeModel.object(cached: server) {
//            completion(model, nil)
//        } else {
//            fetchRemoteNode(server) { node, err in
//                guard node == nil else {
//                    return completion(node,err)
//                }
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                    fetchRemoteNode(server, completion: completion)
//                }
//            }
//        }
//    }
//
//    private static func fetchRemoteNode(_ server: String, completion: @escaping ( NodeModel?, Error?)->()) {
//        fetchFirstConfigAndDropIt(server) { dict, err in
//            if let dict = dict, let model = NodeModel.deserialize(from: dict) {
//                // Cache node
//                if SystemModel.current?.disable_cache_node == false {
//                    model.cache()
//                }
//                completion(model, nil)
//            } else {
//                completion(nil, err)
//            }
//        }
//    }
//
//    private static func fetchFirstConfigAndDropIt(_ server: String, completion: @escaping ([String: Any]?, Error?)->()) {
//        let collectionRef = Firestore.firestore().collection(server)
//        collectionRef.order(by: "id", descending: false)
//            .limit(to: 2)   //每次取2个，最后一个是游标（用于添加更多账号），不能被使用
//            .getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                debugPrint("Error getting documents: \(err)")
//                completion(nil, err)
//            } else {
//                guard let documents = querySnapshot?.documents, let document = documents.first, documents.count == 2 else {
//                    debugPrint("empty getting documents = \(querySnapshot?.documents.count ?? 0)")
//                    completion(nil, MVError(code: .unknown, message: "Empty data"))
//                    return
//                }
//                    debugPrint("\(document.documentID) => \(document.data())")
//
//                    collectionRef.document(document.documentID).delete() { err in
//                        if let err = err {
//                            debugPrint("Error removing document: \(err)")
//                            completion(nil, err)
//                        } else {
//                            debugPrint("Document successfully removed!")
//                            completion(document.data(), nil)
//                        }
//                    }
//            }
//        }
//
//    }
}

extension MVDataManager {
    
    static func fetchAppConfig() {
        
        // App config will set free days vip
        let oldVIP = MVConfigModel.isVIP()
        shared.fetchAppConfig { dict, err in
            
            let newVIP = MVConfigModel.isVIP()
            if newVIP != oldVIP && newVIP == true {
                MVDataManager.fetchLocationListWhenUserBecomeVIP()
            }
            
            if !SystemModel.isAllowedRegion {
                PresentAlert(title: "Sorry, not yet available in your region", message: "", allowButtonTitle: nil, denyButtonTitle: "OK", cancelCompletion:  {
                    exit(0)
                })
            }
        }
    }
    
    private func fetchAppConfig(completion: @escaping ([String: Any]?, Error?)->()) {
//        let collectionRef = Firestore.firestore().collection("config").document("app")
//        collectionRef.getDocument { snapshot, err in
//            guard err == nil else {
//                debugPrint("Error getting documents: \(err)")
//                completion(nil, err)
//                return
//            }
//
//            guard let snapshot = snapshot else {
//                debugPrint("empty fetchAppConfig")
//                completion(nil, MVError(code: .unknown, message: "Empty data"))
//                return
//            }
//
//            if let model = SystemModel.deserialize(from: snapshot.data()) {
//                SystemModel.current = model
//                SystemModel.saveToFile()
//
//                debugPrint("fetched app config = \(model.toJSONString())")
//
//            }
//
//            completion(snapshot.data(), nil)
//        }
    }
}
