//
//  PKDNSCacher.swift
//  PKit
//
//  Created by Plumk on 2025/3/5.
//

import Foundation

final class PKDNSCacher {
    
    private let locker = NSLock()
    private var cache = [String: CacheInfo]()
    
    
    func store(domain: String, packet: PKDNSPacket) {
        self.locker.withLock {
            let info = CacheInfo(pkt: packet, time: time(nil))
            self.cache[domain] = info
        }
    }
    
    func read(domain: String) -> PKDNSPacket? {
        return self.locker.withLock {
            guard let info = self.cache.removeValue(forKey: domain) else {
                return nil
            }
            
            let now = time(nil)
            let ttl: UInt32
            if info.pkt.Answers.count > 0 {
                ttl = info.pkt.Answers[0].ttl
            } else {
                ttl = 300
            }
            
            if now - info.time > ttl {
                return nil
            }
            
            self.cache[domain] = info
            return info.pkt
        }
    }
}


extension PKDNSCacher {
    struct CacheInfo {
        let pkt: PKDNSPacket
        let time: time_t
    }
}
