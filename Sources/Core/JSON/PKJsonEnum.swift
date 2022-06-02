//
//  PKJsonEnum.swift
//
//  Created by Plumk on 2022/6/2.
//

import Foundation

public protocol PKJsonEnum: PKJsonTransformable {
    static func _transform(from object: Any) -> Self?
    func _plainValue() -> Any?
}


public extension RawRepresentable where Self: PKJsonEnum {
    
    static func _transform(from object: Any) -> Self? {
        
        if let rawValue = (RawValue.self as? _PKJsonTransformable.Type)?._transform(from: object) as? RawValue {
            return .init(rawValue: rawValue)
        }
        return nil
    }
    
    func _plainValue() -> Any? {
        return self.rawValue
    }
    
}
