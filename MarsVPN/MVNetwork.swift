//
//  NOHVNetworkYY.swift
//
//  Created by Spike on 2019/09/16.
//

import Foundation
import Moya
import SwifterSwift
import SwiftyJSON

public typealias StringCompletion = (_ result: Result<String?, Swift.Error>) -> Void
public typealias JSONCompletion = (_ result: Result<JSON?, Swift.Error>) -> Void


/// Default network provider, singleton
/// usage:
///
///     NOHVNetworkYY.shared.request(TestAPI.test, ...)
///
/// or you can create custom `MoyaProvider` like `NOHVNetworkYY`
class MVNetwork: MoyaProvider<MultiTarget> {

    static let shared = MVNetwork()

    init() {
        let plugins = [PluginType]()
        super.init(plugins: plugins)
    }

    @discardableResult
    open class func request(_ target: TargetType,
                      completion: @escaping JSONCompletion) -> Cancellable {
        self.shared.request(target) { (result) in
            switch result {
            case .success(let str):
                if let str = str {
                    completion(.success(str))
                } else {
                    completion(.failure(MVError(code: .unknown, message: "")))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }


    /// Wrap target as MultiTarget to call `MoyaProvider`'s implement
    /// error will be APIError or MoyaError
    @discardableResult
    open func request(_ target: TargetType,
                      completion: @escaping JSONCompletion) -> Cancellable {
        
        return super.request(MultiTarget(target)) { result in
            do {
                let response = try result.get()
                let json = JSON(response.data)

//                guard let code = json["status"].int else {
//                    return completion(.failure(MoyaError.requestMapping("")))
//                }
                
                #if DEBUG
                print("target = \(target)")
                print("param = \(target.task)")
                print("request response = \(response)")
                print("response data = \(response.data)")
                print("response str = \(try response.mapString())")
                print("JSON(response.data) = \(json.dictionaryObject)")
                #endif
                
//                if code == 1 {
                    completion(.success(json))
//                } else {
//                    completion(.failure(HVError(code: .unknown, message: "")))
//                }
            } catch let error as MoyaError {
                completion(.failure(error))
            } catch {
                completion(.failure(error))
            }
        }
    }
    


}
