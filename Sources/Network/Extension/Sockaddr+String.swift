//
//  Sockaddr+String.swift
//
//  Created by Plumk on 2022/6/16.
//

import Foundation


public extension sockaddr {
    
    var ipStr: String? {
        if self.sa_family == AF_INET {
            return withUnsafeBytes(of: self, {
                $0.bindMemory(to: sockaddr_in.self).baseAddress?.pointee.ipStr
            })
        } else {
            return withUnsafeBytes(of: self, {
                return $0.bindMemory(to: sockaddr_in6.self).baseAddress?.pointee.ipStr
            })
        }
    }
    
    var port: UInt16 {
        if self.sa_family == AF_INET {
            return withUnsafeBytes(of: self, {
                $0.bindMemory(to: sockaddr_in.self).baseAddress!.pointee.port
            })
        } else {
            return withUnsafeBytes(of: self, {
                return $0.bindMemory(to: sockaddr_in6.self).baseAddress!.pointee.port
            })
        }
    }
    
    var size: UInt32 {
        if self.sa_family == AF_INET {
            return UInt32(MemoryLayout<sockaddr_in>.size)
        }
        
        return UInt32(MemoryLayout<sockaddr_in6>.size)
    }
}

public extension sockaddr_in {
    
    var ipStr: String? {
        return String(fromIP4: self.sin_addr.s_addr.bytes)
    }
    
    var port: UInt16 {
        return self.sin_port
    }
}

public extension sockaddr_in6 {
    
    var ipStr: String? {
        return String(fromIP6: self.sin6_addr.bytes)
    }
    
    var port: UInt16 {
        return self.sin6_port
    }
}
