//
//  PKJsonTransformable.swift
//
//  Created by Plumk on 2022/6/2.
//

import Foundation

public protocol PKJsonTransformable { }

extension PKJsonTransformable {
    static func _transform(from object: Any) -> Self? {
        
        switch self {
        case let transform as _PKJsonTransformable.Type:
            return transform._transform(from: object) as? Self
        
        case let transform as PKJsonEnum.Type:
            return transform._transform(from: object) as? Self
            
        default:
            return nil
        }
    }
    
    func _plainValue() -> Any? {
        switch self {
        case let transform as _PKJsonTransformable:
            return transform._plainValue()
        
        case let transform as PKJsonEnum:
            return transform._plainValue()
            
        default:
            return nil
        }
    }
}

protocol _PKJsonTransformable {
    static func _transform(from object: Any) -> Self?
    func _plainValue() -> Any?
}
