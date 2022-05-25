//
//  PKJsonKey.swift
//  
//
//  Created by Plumk on 2022/5/25.
//

import Foundation

protocol JsonKeyWrapper {
    func setValue(_ value: Any)
}

/// JSOS key包装器
@propertyWrapper public class JsonKey<Value>: JsonKeyWrapper, CustomStringConvertible {
    
    public var wrappedValue: Value
    
    public init(wrappedValue value: Value) {
        self.wrappedValue = value
    }
    
    
    // MARK: - CustomStringConvertible
    public var description: String {
        var output = ""
        print(self.wrappedValue, separator: "", terminator: "", to: &output)
        return output
    }
    
    // MARK: - JsonKeyWrapper
    func setValue(_ value: Any) {
        
        if let obj = self.wrappedValue as? PKJson {
            
            switch value {
            case let str as String:
                obj.update(from: str)
                
            case let str as Data:
                obj.update(from: str)
                
            case let str as [String: Any]:
                obj.update(from: str)
                
            default:
                break
            }
            
            return
        }
        
        
        if let x = value as? Value {
            self.wrappedValue = x
        }
    }
}
