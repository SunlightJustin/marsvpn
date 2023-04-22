//
//  FileManagerModel.swift
//  Kinker
//
//  Created by clove on 7/22/20.
//  Copyright © 2020 personal.Justin. All rights reserved.
//

import Foundation
import HandyJSON

private let fileQueue = DispatchQueue(label: "uiew" + "fileQueue")

protocol FileManagerProtocol: HandyJSON {
    func saveToFile()
    static func deleteFile()
    static func loadFromFile() -> Self?
    static func fileURL() -> URL
    static func fileNameSuffix() -> String?
}

extension FileManagerProtocol {
    
    public func saveToFile() {
          do {
              let data = toJSONString()?.data(using: .utf8)
              try data?.write(to: Self.fileURL())
          } catch {
              debugPrint(error)
          }
    }

    static func deleteFile() {
          guard FileManager.default.fileExists(atPath: fileURL().path) else {
              debugPrint("user file not exists, no need delete")
              return
          }

          do {
              try FileManager.default.removeItem(at: fileURL())
          } catch {
              debugPrint(error)
          }
    }
        
    static func fileURL() -> URL {
          guard let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
              fatalError("Where did Documents go?!")
          }

        let fileName = AppInfo.uniquePrefix + (fileNameSuffix() ?? "")
          let filePath = documentsPath.appendingPathComponent(fileName)
          debugPrint(filePath)

        return URL(fileURLWithPath: filePath)
    }
    
    static func fileNameSuffix() -> String? {
        print("className=\(type(of:self))")
        return NSStringFromClass(type(of: Self()) as! AnyClass)
    }
    
    static func loadFromFile() -> Self? {
        guard FileManager.default.fileExists(atPath: fileURL().path) else {
              debugPrint("user file not exists")
              return nil
          }

          do {
              let data = try Data(contentsOf: fileURL())
              let user = JSONDeserializer<Self>.deserializeFrom(json: String(data: data, encoding: .utf8))
              return user
          } catch {
              debugPrint(error)
          }

        return nil
    }
}

public class FileManagerModel: FileManagerProtocol {
    
//    private static let ioQueue = DispatchQueue(label: "uiew" + "ioQueue")
//    private static var _current: FileManagerProtocol?
//
    required public init() {}

//
//    static var current: FileManagerProtocol? {
//        set {
//            fileQueue.sync {
//                _current = newValue
//            }
//            fileQueue.async {
//                if let user = _current {
//                    user.saveToFile()
//                } else {
//                    deleteFile()
//                }
//            }
//        }
//
//        get {
//            /// Not very thread-safe, there may be some data anomalies
//            /// but it won't crash, for performance first.
//            if let user = _current {
//                return user
//            }
//
//            fileQueue.sync {
//                _current = loadFromFile()
//            }
//
//            if _current == nil {
//                _current = Self()
//            }
//
//            return _current
//        }
//    }
}

extension FileManagerModel {
}
