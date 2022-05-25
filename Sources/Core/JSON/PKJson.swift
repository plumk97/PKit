//
//  PKJson.swift
//  
//
//  Created by Plumk on 2022/5/25.
//

import Foundation

public protocol PKJson {
    init()
}


// MARK: - Keys
extension PKJson {
    
    func fetchJsonKeys() -> [String: JsonKeyWrapper] {
        
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
        
        let keys = self.fetchJsonKeys()
        
        for (key, value) in dict {
            keys["_" + key]?.setValue(value)
        }
    }

}
