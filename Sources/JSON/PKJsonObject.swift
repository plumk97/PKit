//
//  PKJsonObject.swift
//  
//
//  Created by Plumk on 2022/5/26.
//

import Foundation

/// 可解析的Json数据类型
public protocol PKJsonObject {
}

extension PKJsonObject {
    func toDict() -> [String: Any]? {
        return (self as? _PKJsonObject)?.toDict()
    }
}

protocol _PKJsonObject {
    func toDict() -> [String: Any]?
}

extension String: _PKJsonObject, PKJsonObject {
    func toDict() -> [String : Any]? {
        return self.data(using: .utf8)?.toDict()
    }
}

extension Data: _PKJsonObject, PKJsonObject {
    func toDict() -> [String : Any]? {
        let dict = try? JSONSerialization.jsonObject(with: self, options: .fragmentsAllowed) as? [String: Any]
        return dict
    }
}

extension Dictionary: _PKJsonObject, PKJsonObject {
    func toDict() -> [String : Any]? {
        return self as? [String: Any]
    }
}

extension NSDictionary: _PKJsonObject, PKJsonObject {
    func toDict() -> [String : Any]? {
        return self as? [String: Any]
    }
}

