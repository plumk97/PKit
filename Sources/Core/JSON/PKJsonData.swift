//
//  PKJsonData.swift
//  
//
//  Created by Plumk on 2022/5/26.
//

import Foundation

/// 可解析的Json数据类型
public protocol PKJsonData {
    func toDict() -> [String: Any]?
}

extension String: PKJsonData {
    public func toDict() -> [String : Any]? {
        return self.data(using: .utf8)?.toDict()
    }
}

extension Data: PKJsonData {
    public func toDict() -> [String : Any]? {
        let dict = try? JSONSerialization.jsonObject(with: self, options: .fragmentsAllowed) as? [String: Any]
        return dict
    }
}

extension Dictionary: PKJsonData where Key == String {
    public func toDict() -> [String : Any]? {
        return self
    }
}


