//
//  Test.swift
//  MMKV-Test
//
//  Created by 岳云石 on 2023/9/18.
//

import UIKit

@objc public class Test: NSObject {
    private static let CDPQueue = DispatchQueue(label: "com.yys.CDP.queue", attributes: .concurrent)
    
    @objc public static func put() {
        CDPQueue.async(flags: .barrier) {
            var dic: [String : Any] = [:]
            for _ in (0..<20) {
                dic[String(Double.random(in: 0...1))] = String(Double.random(in: 0...1))
            }
            Cache.storageObject(dic, filePath: Cache.cacheStoragePath(withFileName: "YYS"))
        }
    }
    
    @objc public static func get() -> Any? {
        var result: Any? = nil
        //使用sync拿到返回值之后再return
        CDPQueue.sync {
            result = Cache.loadObject(withFilePath: Cache.cacheStoragePath(withFileName: "YYS"))
        }
        
        return result;
    }
}
