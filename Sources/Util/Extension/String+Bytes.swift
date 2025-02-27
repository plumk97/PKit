//
//  String+Bytes.swift
//
//  Created by Plumk on 2022/1/9.
//

import Foundation


extension String {

    public var hexBytes: Data {
        
        var bytes = Data()
        
        var i = 0
        var chars = [String.Element]()
        
        func convertUInt(_ chars: [String.Element]) -> UInt32 {
            let sc = Scanner(string: String(chars))
            
            var p: UInt32 = 0
            if #available(OSX 10.15, iOS 13.0, *) {
                p = UInt32(sc.scanInt32(representation: .hexadecimal) ?? 0)
            } else {
                sc.scanHexInt32(&p)
            }
            return p
        }
        
        while i < self.count {
            let char = self[i]
            i += 1
            guard char != " " else {
                continue
            }
            
            chars.append(char)
            if chars.count >= 2 {
                bytes.append(UInt8(truncatingIfNeeded: convertUInt(chars)))
                chars.removeAll()
            }
        }
        
        if chars.count > 0 {
            bytes.append(UInt8(truncatingIfNeeded: convertUInt(chars)))
        }
        
        return bytes
    }
}
