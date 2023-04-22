//
//  LocationModel.swift
//  GOGOVPN
//
//  Created by Justin on 2022/6/27.
//

import Foundation
import HandyJSON

public final class LocationModel: HandyJSON, Equatable, NSCopying {
    
    var id: String?
    var name: String?
    var level0: String?
    var level1: String?
    var level2: String?
    var country_code: String?
    var remark: String?
    var free: Bool?
    var image: String?               //image path
    var rules: [String: Any]?
    var children: [LocationModel]?
    
    required public init() { }

    public static func == (lhs: LocationModel, rhs: LocationModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let str = self.toJSONString()
        return LocationModel.deserialize(from: str)
    }
    
    func displayName() -> String? {
        var name = self.level0 ?? ""
        if let level1 = level1, level1.count > 0 {
            name += " - \(level1)"
        }
        return name
    }
    
    func flagImage() -> UIImage? {
        guard let code = country_code?.lowercased() else { return nil }
        return UIImage(named: "flag_\(code)")
    }
    
    var serverIP: String? {
        return rules?["address"] as? String
    }
}
