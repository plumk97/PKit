//
//  DNSPacketTests.swift
//  PKit
//
//  Created by Plumk on 2025/9/14.
//

import Foundation
import XCTest
@testable import PKNetwork


final class DNSPacketTests: XCTestCase {
    
    
    func testDecode() throws {
        // bcba010000010000000000000377777705626169647503636f6d0000010001
        let pkt = try PKDNSPacket(data: "bcba010000010000000000000377777705626169647503636f6d0000010001".hexBytes)
        print(pkt)
        print(pkt.encode().hexString)
        
        // BCBA010000010000000000000377777705626169647503636F6D0000010001
        
    }
}
