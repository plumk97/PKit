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
    func didFinishMapping()
}

public extension PKJson {
    func willStartMapping() {}
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
    
    public static func decode(_ jsonObject: PKJsonObject?, designatedPath: String? = nil) -> Self {
        let model = Self.init()
        model.update(from: jsonObject)
        return model
    }
}


// MARK: - Update
extension PKJson {
    
    public func update(from jsonObject: PKJsonObject?, designatedPath: String? = nil) {

        guard let dict = fetchDict(jsonObject?.toDict(), designatedPath: designatedPath) as? [String: Any] else {
            return
        }
        
        
        let properties = self.fetchProperties()
        self.willStartMapping()
        
        for (key, value) in dict {
            
            
            guard let wrapper = properties["_" + key] else {
                continue
            }
            
            let obj = self as? NSObject
            obj?.willChangeValue(forKey: key)
            wrapper.setValue(value)
            obj?.didChangeValue(forKey: key)
        }
        
        self.didFinishMapping()
    }
}

// MARK: - Array
extension Array where Element: PKJson {
    
    // MARK: - Decode
    public static func decode(_ jsonObject: PKJsonObject?, designatedPath: String? = nil) -> Self? {
        guard let dicts = fetchDict(jsonObject?.toDict(), designatedPath: designatedPath) as? [[String: Any]] else {
            return nil
        }
        
        return self.decode(dicts)
        
    }
    
    public static func decode(_ jsonObjects: [PKJsonObject]?) -> Self? {
        guard let jsonObjects = jsonObjects else {
            return nil
        }

        var array = Self()
        for jsonObject in jsonObjects {
            array.append(.decode(jsonObject))
        }
        
        return array
    }
    
    
    // MARK: - Encode
    
    public func toJson() -> [[String: Any]] {
        
        var dicts = [[String: Any]]()
        for element in self {
            dicts.append(element.toJson())
        }
        
        return dicts
    }
    
    public func toJsonString() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self.toJson(), options: .fragmentsAllowed) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}


fileprivate func fetchDict(_ dict: [String: Any]?, designatedPath: String? = nil) -> Any? {
    guard let dict = dict else {
        return nil
    }
    
    var obj: Any = dict
    
    if let designatedPath = designatedPath {
        let paths = designatedPath.components(separatedBy: ".")
        for path in paths {
            
            if let x = (obj as? [String: Any])?[path] {
                obj = x
            } else {
                break
            }
        }
    }
    
    return obj
}
