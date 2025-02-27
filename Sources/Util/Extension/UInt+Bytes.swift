//
//  UInt+Bytes.swift
//
//  Created by Plumk on 2022/1/9.
//

import Foundation

// MARK: - UInt <--> Bytes
extension UInt16 {

    public init<T: Collection>(_ source: T) where T.Element == UInt8, T.Index == Int {
        
        if source.count >= 2 {
            let offset = source.startIndex
            
            var v: UInt16 = 0
            v = UInt16(source[offset + 0]) << 8
            v |= UInt16(source[offset + 1])
            self = v
        } else {
            self = 0
        }
    }
    
    public var bytes: [UInt8] {
        return [UInt8.init(truncatingIfNeeded: self >> 8),
                UInt8.init(truncatingIfNeeded: self)]
    }
}

extension UInt32 {
    
    public init<T: Collection>(_ source: T) where T.Element == UInt8, T.Index == Int {
        if source.count >= 4 {
            let offset = source.startIndex
            
            var v: UInt32 = 0
            v = UInt32(source[offset + 0]) << 24
            v |= UInt32(source[offset + 1]) << 16
            v |= UInt32(source[offset + 2]) << 8
            v |= UInt32(source[offset + 3])
            self = v
        } else {
            self = 0
        }
    }
    
    public var bytes: [UInt8] {
        return [UInt8.init(truncatingIfNeeded: self >> 24),
                UInt8.init(truncatingIfNeeded: self >> 16),
                UInt8.init(truncatingIfNeeded: self >> 8),
                UInt8.init(truncatingIfNeeded: self)]
    }
}


extension UInt64 {
    
    public init<T: Collection>(_ source: T) where T.Element == UInt8, T.Index == Int {
        if source.count >= 4 {
            let offset = source.startIndex
            
            var v: UInt64 = 0
            v = UInt64(source[offset + 0]) << 56
            v |= UInt64(source[offset + 1]) << 48
            v |= UInt64(source[offset + 2]) << 40
            v |= UInt64(source[offset + 3]) << 32
            v |= UInt64(source[offset + 4]) << 24
            v |= UInt64(source[offset + 5]) << 16
            v |= UInt64(source[offset + 6]) << 8
            v |= UInt64(source[offset + 7])
            self = v
        } else {
            self = 0
        }
    }
    
    public var bytes: [UInt8] {
        return [UInt8.init(truncatingIfNeeded: self >> 56),
                UInt8.init(truncatingIfNeeded: self >> 48),
                UInt8.init(truncatingIfNeeded: self >> 40),
                UInt8.init(truncatingIfNeeded: self >> 32),
                UInt8.init(truncatingIfNeeded: self >> 24),
                UInt8.init(truncatingIfNeeded: self >> 16),
                UInt8.init(truncatingIfNeeded: self >> 8),
                UInt8.init(truncatingIfNeeded: self)]
    }
}
