//
//  PKStringTransform.swift
//
//  Created by Plumk on 2022/6/2.
//

import Foundation


protocol PKStringTransform: _PKJsonTransformable,  PKJsonTransformable { }

extension PKStringTransform {
    static func _transform(from object: Any) -> String? {
        
        switch object {
        case let str as String:
            return str
            
        case let num as NSNumber:
            if NSStringFromClass(type(of: num)) == "__NSCFBoolean" {
                if num.boolValue {
                    return "true"
                } else {
                    return "false"
                }
            }
            
            return num.stringValue
            
        default:
            return "\(object)"
        }
    }
    
    func _plainValue() -> Any? {
        return self
    }
}

extension String: PKStringTransform {}
