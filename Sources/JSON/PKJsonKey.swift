//
//  PKJsonKey.swift
//  
//
//  Created by Plumk on 2022/5/25.
//

import Foundation

protocol JsonKeyWrapper {
    var name: String? { get }
    func setValue(_ value: Any)
    func getValue() -> Any
}

/// JSOS key包装器
@propertyWrapper public class JsonKey<Value>: JsonKeyWrapper, CustomStringConvertible {
    
    public var wrappedValue: Value
    
    let customTransform: PKCusomTransformable?
    let name: String?
    
    public init(wrappedValue value: Value, transform: PKCusomTransformable? = nil, name: String? = nil) {
        self.wrappedValue = value
        self.customTransform = transform
        self.name = name
    }
    
    
    // MARK: - CustomStringConvertible
    public var description: String {
        var output = ""
        print(self.getValue(), separator: "", terminator: "", to: &output)
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
        
        if let obj = self.wrappedValue as? RxTransformable {
            obj.transform(from: value)
            return
        }
        
        
        if let value = value as? Value {
            self.wrappedValue = value
        } else if let transform = self.customTransform, let value = transform.transformFromJSON(value) as? Value {
            self.wrappedValue = value
        } else if let value = (Value.self as? PKJsonTransformable.Type)?._transform(from: value) as? Value {
            self.wrappedValue = value
        }
        
    }
    
    func getValue() -> Any {
        
        if let transform = self.customTransform {
            return transform.transformToJSON(self.wrappedValue) as Any
        }
        
        if let transform = self.wrappedValue as? RxTransformable {
            return transform.plainValue() as Any
        }
        
        return self.wrappedValue
    }
}
