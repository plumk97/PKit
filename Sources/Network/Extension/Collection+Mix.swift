//
//  Collection+Mix.swift
//
//  Created by Plumk on 2022/1/9.
//

import Foundation


extension Collection where Self.Element == UInt8, Self.Index == Int {
    
    public var hexString: String {
        var hex = ""
        for byte in self {
            hex += String.init(format: "%02X", byte)
        }
        return hex
    }
    
    public func mixBytes(key: Data) -> Data {
        var mixData = Array<UInt8>.init(repeating: 0, count: self.count)
        
        let keylen = key.count
        var keyIdx = 0
        var i = mixData.startIndex
        for byte in self {
            mixData[i] = byte ^ key[keyIdx % keylen]
            i += 1
            keyIdx += 1
        }
        return mixData.toData()
    }
}


extension Collection where Self.Element == UInt8 {
    public func toData() -> Data {
        return Data(self)
    }
}

extension UInt8 {
    public func mixByte(key: [UInt8]) -> UInt8 {
        return self ^ key[0]
    }
}
