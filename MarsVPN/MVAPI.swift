//
//  NOCustomerAPI.swift
//
//  Created by Spike on 2019/09/17.
//

import Foundation
import Moya

public enum MVAPI {
    case fetchList
//    case subscribe(subscribe_id: String, subscribe_type: String, subscribe_price: Double, subscribe_currency: String, subscribe_trial_days: Int?=nil)
//    case reward(revenue: NSDecimalNumber, ip: String?=nil, placement: String, currency: String?)
}

extension MVAPI: TargetType {

    public var path: String {
        switch self {
        case .fetchList: return "/"
        }
    }

    public var method: Moya.Method {
        switch self {
//        case .ser: return .get
        default: return .get
        }
    }

    public var task: Task {
        switch self {
        case .fetchList:
            return .requestParameters(parameters: [:], encoding: URLEncoding.queryString)
        }
    }
}

extension MVAPI {
    
    public var baseURL: URL {
        return URL(string: "https://nameless-fire-ff5c.markso.workers.dev")!
    }

    public var sampleData: Data {
        return Data()
    }

    public var headers: [String: String]? {
        var headers = [String: String]()
//        headers["Content-Type"] = "application/x-www-form-urlencoded"
        return headers
    }

    var needstoken: Bool {
        return false
    }
}


