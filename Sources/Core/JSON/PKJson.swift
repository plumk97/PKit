//
//  PKJson.swift
//  
//
//  Created by Plumk on 2022/5/25.
//

import Foundation

public protocol PKJson {
    init()
    
    func willStartMapping()
    func mapping()
    func didFinishMapping()
}

public extension PKJson {
    func willStartMapping() {}
    func mapping() {}
    func didFinishMapping() {}
}


// MARK: - Properties
extension PKJson {

    func fetchProperties() -> [String: JsonKeyWrapper] {
        
        let mirror = Mirror(reflecting: self)
        
        var keys = [String: JsonKeyWrapper]()
        for child in mirror.children {
            if let wrapper = child.value as? JsonKeyWrapper, let name = child.label {
                keys[name] = wrapper
            }
        }
        
        return keys
    }
    
}


// MARK: - Encode
extension PKJson {
    
    public func toJson() -> [String: Any] {
        
        let properties = self.fetchProperties()
        
        var dict = [String: Any]()
        for (key, value) in properties {
            
            let key = String(key[key.index(key.startIndex, offsetBy: 1)...])
            let value = value.getValue()
            
            if let json = value as? PKJson {
                dict[key] = json.toJson()
            } else if let value = (value as? PKJsonTransformable)?._plainValue() {
                dict[key] = value
            }
        }
        
        return dict
    }
    
    public func toJsonString() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self.toJson(), options: .fragmentsAllowed) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}

// MARK: - Decode
extension PKJson {
    
    public static func decode(_ jsonData: PKJsonData?) -> Self {
        let model = Self.init()
        model.update(from: jsonData)
        return model
    }
}


// MARK: - Update
extension PKJson {
    
    public func update(from jsonData: PKJsonData?) {

        guard let dict = jsonData?.toDict() else {
            return
        }
        
        let properties = self.fetchProperties()
        
        for (key, value) in dict {
            let obj = self as? NSObject
            
            obj?.willChangeValue(forKey: key)
            properties["_" + key]?.setValue(value)
            obj?.didChangeValue(forKey: key)
        }
    }
}
