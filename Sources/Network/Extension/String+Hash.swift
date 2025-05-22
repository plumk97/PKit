//
//  String+Hash.swift
//
//  Created by Plumk on 2022/7/7.
//

import Foundation
import CommonCrypto

extension String {
    
    public var md5: [UInt8] {
        self.withCString({
            var out = [UInt8].init(repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5($0, CC_LONG(strlen($0)), &out)
            return out
        })
    }
    
    public var sha256: [UInt8] {
        
        self.withCString({
            var out = [UInt8].init(repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            CC_SHA256($0, CC_LONG(strlen($0)), &out)
            return out
        })
    }
}
