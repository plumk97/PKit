//
//  in6_addr+bytes.swift
//
//  Created by Plumk on 2022/6/29.
//

import Foundation

extension in6_addr {
    
    public init(from bytes: [UInt8]) {
        self.init(__u6_addr: .init(__u6_addr8: (
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        )))
    }
    
    public var bytes: [UInt8] {
        let b = self.__u6_addr.__u6_addr8
        return [
            b.0, b.1, b.2, b.3,
            b.4, b.5, b.6, b.7,
            b.8, b.9, b.10, b.11,
            b.12, b.13, b.14, b.15,
        ]
    }
}
