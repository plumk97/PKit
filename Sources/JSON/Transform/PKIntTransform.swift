//
//  PKIntTransform.swift
//
//  Created by Plumk on 2022/6/2.
//

import Foundation


protocol PKIntTransform: FixedWidthInteger, _PKJsonTransformable, PKJsonTransformable {
    init?(_ text: String, radix: Int)
    init(truncating number: NSNumber)
}

extension PKIntTransform {
    
    static func _transform(from object: Any) -> Self? {
        switch object {
        case let str as String:
            return Self(str, radix: 10)
            
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

extension Int: PKIntTransform {}
extension UInt: PKIntTransform {}
extension Int8: PKIntTransform {}
extension Int16: PKIntTransform {}
extension Int32: PKIntTransform {}
extension Int64: PKIntTransform {}
extension UInt8: PKIntTransform {}
extension UInt16: PKIntTransform {}
extension UInt32: PKIntTransform {}
extension UInt64: PKIntTransform {}
