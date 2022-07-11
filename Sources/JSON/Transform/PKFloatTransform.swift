//
//  PKFloatTransform.swift
//  
//
//  Created by Plumk on 2022/7/11.
//

import Foundation


protocol PKFloatTransform: BinaryFloatingPoint, _PKJsonTransformable, PKJsonTransformable {
    init?<S>(_ text: S) where S: StringProtocol
    init(truncating number: NSNumber)
}

extension PKFloatTransform {
    
    static func _transform(from object: Any) -> Self? {
        switch object {
        case let str as String:
            return Self(str)
            
        case let num as NSNumber:
            return Self(truncating: num)
            
        default:
            return nil
        }
    }
    
    func _plainValue() -> Any? {
        return self
    }
}

extension Float: PKFloatTransform {}
extension Double: PKFloatTransform {}
