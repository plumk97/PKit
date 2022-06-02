//
//  PKIntTransfrom.swift
//
//  Created by Plumk on 2022/6/2.
//

import Foundation


protocol PKIntTransfrom: FixedWidthInteger, PKTransfrom {
    init?(_ text: String, radix: Int)
    init(truncating number: NSNumber)
}

extension PKIntTransfrom {
    
    static func transform(from object: Any) -> Self? {
        switch object {
        case let str as String:
            return Self(str, radix: 10)
            
        case let num as NSNumber:
            return Self(truncating: num)
            
        default:
            return nil
        }
    }
}

extension Int: PKIntTransfrom {}
extension UInt: PKIntTransfrom {}
extension Int8: PKIntTransfrom {}
extension Int16: PKIntTransfrom {}
extension Int32: PKIntTransfrom {}
extension Int64: PKIntTransfrom {}
extension UInt8: PKIntTransfrom {}
extension UInt16: PKIntTransfrom {}
extension UInt32: PKIntTransfrom {}
extension UInt64: PKIntTransfrom {}
