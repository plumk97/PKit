//
//  Collection+Hash.swift
//

import Foundation
import CommonCrypto

extension Collection where Self.Element == UInt8, Self.Index == Int {
    
    public var md5: [UInt8] {
        let data = Data(self)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        _ = data.withUnsafeBytes {
            CC_MD5($0.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest
    }
    
    public var sha256: [UInt8] {
        let data = Data(self)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = data.withUnsafeBytes {
            CC_SHA256($0.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest
    }
}
