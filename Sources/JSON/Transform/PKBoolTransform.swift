//
//  PKBoolTransform.swift
//
//  Created by Plumk on 2022/6/2.
//

import Foundation

extension Bool: PKJsonTransformable {}
extension Bool: _PKJsonTransformable {
    static func _transform(from object: Any) -> Bool? {
        switch object {
        case let str as NSString:
            let lowerCase = str.lowercased
            if ["0", "false"].contains(lowerCase) {
                return false
            }
            if ["1", "true"].contains(lowerCase) {
                return true
            }
            return nil
            
        case let num as NSNumber:
            return num.boolValue
            
        default:
            return nil
        }
    }
    
    func _plainValue() -> Any? {
        return self
    }
}
