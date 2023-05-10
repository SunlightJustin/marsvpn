//
//  NOCustomerAPI.swift
//
//  Created by Spike on 2019/09/17.
//

import Foundation
import Moya

public enum MVAPISystemConfig {
    case fetch
}

extension MVAPISystemConfig: TargetType {

    public var path: String {
        switch self {
        case .fetch: return "/"
        }
    }

    public var method: Moya.Method {
        switch self {
        default: return .get
        }
    }

    public var task: Task {
        switch self {
        case .fetch:
            return .requestParameters(parameters: [:], encoding: URLEncoding.queryString)
        }
    }
}

extension MVAPISystemConfig {
    
    public var baseURL: URL {
        return URL(string: "https://green-lake-3dd3.markso.workers.dev")!
    }

    public var sampleData: Data {
        return Data()
    }

    public var headers: [String: String]? {
        var headers = [String: String]()
        return headers
    }

    var needstoken: Bool {
        return false
    }
}


