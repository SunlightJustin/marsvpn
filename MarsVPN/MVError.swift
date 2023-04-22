//
//  GGError.swift
//
//  Created by Spike on 2019/09/18.
//

import Foundation
//import Moya
//import HandyJSON

public struct MVError: Swift.Error {

    enum Code: Int {
        case parseJSONError = -999
        case responseError = -998
        case requestFailedError = -997
        case unknown = -996

        
        var errorMessage: String? {
            switch self {
            case .requestFailedError: return "Permission denied"
//            case .payError: return nil
            default: return nil
            }
        }
        
    }

    let code: Code
    let message: String
}

extension Error {
    var localizedMessage: String {
        if let error = self as? MVError {
            return error.code.errorMessage ?? error.message
//        } else if self is MoyaError {
//            return "Server connection failed, please try again later."
        } else {
            return localizedDescription
        }
    }
}

//public extension Moya.Response {
//    internal func filterGGError<T: HandyJSON>(_ type:T.Type, failsOnEmptyData: Bool = true) throws -> DataModel<T> {
//
//        guard (200...209) ~= self.statusCode else {
//            throw MVError(code: .requestFailedError, message: "")
//        }
//
//        guard let json = try? self.mapJSON(failsOnEmptyData: failsOnEmptyData) as? [String: AnyObject] else  {
//            throw MVError(code: .responseError, message: "")
//        }
//
//        guard let object = JSONDeserializer<DataModel<T>>.deserializeFrom(dict: json) else {
//            throw MVError(code: .parseJSONError, message: "")
//        }
//
//        guard let code = object.code, let message = object.msg else {
//            throw MVError(code: .parseJSONError, message: "2")
//        }
//
//        if code != 0 {
//            throw MVError(code: MVError.Code(rawValue: code) ?? .unknown, message: message)
//        }
//
//        return object
//    }
//}
