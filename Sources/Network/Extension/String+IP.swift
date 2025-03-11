//
//  String+IP.swift
//
//  Created by Plumk on 2022/5/25.
//

import Foundation


// MARK: - To ip bytes
extension String {
    
    /// 是否是本地链路地址
    public var isLocalLink: Bool {
        
        if self.hasPrefix("fe80::") {
            return true
        }
        
        if self.hasPrefix("169.254") {
            return true
        }
        
        return false
    }
    
    /// 是否是本地环回地址
    public var isLoopback: Bool {
        if self == "127.0.0.1" || self == "0:0:0:0:0:0:0:1" || self == "::1" {
            return true
        }
        return false
    }
    
    /// 转换为IPv4 地址数据 大端字节序
    /// - Returns:
    public func toIP4() -> [UInt8]? {
        return self.toIP(family: AF_INET)
    }
    
    /// 转换为IPv6 地址数据
    /// - Returns:
    public func toIP6() -> [UInt8]? {
        return self.toIP(family: AF_INET6)
    }
    
    
    private func toIP(family: Int32) -> [UInt8]? {
        
        let bytes: [UInt8]? = self.withCString({
            
            if family == AF_INET {
                
                let ptr = UnsafeMutablePointer<in_addr>.allocate(capacity: 1)
                defer {
                    ptr.deallocate()
                }
                
                guard inet_pton(family, $0, ptr) > 0 else {
                    return nil
                }
                return ptr.pointee.s_addr.bytes
                
            } else if family == AF_INET6 {
                let ptr = UnsafeMutablePointer<in6_addr>.allocate(capacity: 1)
                defer {
                    ptr.deallocate()
                }
                
                guard inet_pton(family, $0, ptr) > 0 else {
                    return nil
                }
                
                return ptr.pointee.bytes
            }
            
            return nil
        })
        
        return bytes
    }
}

// MARK: - From ip bytes
extension String {
    
    public init?(from sockAddr: UnsafePointer<sockaddr>) {
        
        if sockAddr.pointee.sa_family == AF_INET {
            
            let str = sockAddr.withMemoryRebound(to: sockaddr_in.self, capacity: 1, {
                String.init(fromIP4: $0.pointee.sin_addr.s_addr.bytes)
            })
            
            
            guard let str = str else {
                return nil
            }

            self = str
        } else {
            let str = sockAddr.withMemoryRebound(to: sockaddr_in6.self, capacity: 1, {
                String(fromIP6: $0.pointee.sin6_addr.bytes)
            })
            
            guard let str = str else {
                return nil
            }

            self = str
        }
        
    }
    
    /// IPv4 地址数据转换为字符串 大端字节序
    /// - Parameter bytes:
    public init?(fromIP4 bytes: [UInt8]) {
        guard let str = String.fromIP(bytes, family: AF_INET) else {
            return nil
        }
        self = str
    }
    
    /// IPv6 地址数据转换为字符串
    /// - Parameter bytes:
    public init?(fromIP6 bytes: [UInt8]) {
        guard let str = String.fromIP(bytes, family: AF_INET6) else {
            return nil
        }
        self = str
    }

    private static func fromIP(_ bytes: [UInt8], family: Int32) -> String? {
        
        if family == AF_INET {
            
            let ptr = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(INET_ADDRSTRLEN))
            defer {
                ptr.deallocate()
            }
            
            return withUnsafeBytes(of: UInt32(bytes), {
                if inet_ntop(AF_INET, $0.baseAddress, ptr, socklen_t(INET_ADDRSTRLEN)) != nil {
                    return String.init(cString: ptr)
                }
                return nil
            })
            
        
            
        } else if family == AF_INET6 {
            
            let ptr = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(INET6_ADDRSTRLEN))
            defer {
                ptr.deallocate()
            }
            
            return bytes.withUnsafeBytes({
                if inet_ntop(AF_INET6, $0.baseAddress, ptr, socklen_t(INET6_ADDRSTRLEN)) != nil {
                    return String.init(cString: ptr)
                }
                return nil
            })
        }
        
        
        return nil
    }
    
    
    
    
    
}
