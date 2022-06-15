//
//  PKOptionalTransform.swift
//
//  Created by Plumk on 2022/6/2.
//

import Foundation

extension Optional: PKJsonTransformable {}
extension Optional: _PKJsonTransformable {
    static func _transform(from object: Any) -> Optional<Wrapped>? {
        
        if let value = object as? Wrapped {
            return .some(value)
        }
        
        if let cls = Wrapped.self as? PKJson.Type, let jsonObject = object as? PKJsonObject {
            return .some(cls.decode(jsonObject) as? Wrapped)
        }
        
        if let value = (Wrapped.self as? PKJsonTransformable.Type)?._transform(from: object) as? Wrapped {
            return .some(value)
        }
        return .none
    }
    
    func _plainValue() -> Any? {
        
        switch self {
        case let .some(value):
            if let x = value as? PKJsonTransformable {
                return x._plainValue()
            }
     
            return value
            
        case .none:
            return nil
        }
    }
}
