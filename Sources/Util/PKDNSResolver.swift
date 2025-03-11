//
//  PKDNSResolver.swift
//  PKit
//
//  Created by Plumk on 2025/3/5.
//

import Foundation
import Network
import PKCore

final public actor PKDNSResolver {
   
    public static let shared = PKDNSResolver()
    private let queue = DispatchQueue(label: "dns_resolver")
    private var connection: NWConnection!
    private var completes = [UInt16: PKValueCallback<Data>]()
    private var host: String = "223.5.5.5"
    private var port: UInt16 = 0

    public func initConnect(host: String, port: UInt16) {
        self.host = host
        self.port = port
        self.connect()
    }
    
    public func connect() {
        if let connection = self.connection {
            connection.cancel()
        }
        
        self.connection = NWConnection(to: .hostPort(host: .init(self.host), port: .init(rawValue: self.port)!), using: .udp)
        self.connection.start(queue: self.queue)
        self.listenStateChanged()
    }
    
    private func listenStateChanged() {
        self.connection.stateUpdateHandler = {@Sendable state in
            switch state {
            case .ready:
                Task {
                    await self.read()
                }
                
            case .cancelled:
                fallthrough
            case .failed:
                Task {
                    await self.connect()
                }
                
            default:
                break
            }
        }
    }
    
    private func read() {
        guard self.connection.state == .ready else {
            return
        }
        
        self.connection.receiveMessage { content, contentContext, isComplete, error in
            Task {
                if let content {
                    await self.didReceived(content)
                }
                
                await self.read()
            }
        }
    }
    
    private func didReceived(_ content: Data) {
        let id = UInt16(content[content.startIndex ..< content.startIndex+2])
        if let complete = self.completes.removeValue(forKey: id) {
            complete(content)
        }
    }
    
    private func didWritten(id: UInt16, continuation: CheckedContinuation<Data, Error>) {
        let timeoutTask = DispatchWorkItem {
            self.removeComplete(id: id)
            continuation.resume(throwing: PKStringError(msg: "timeout"))
        }
        
        self.completes[id] = { data in
            continuation.resume(returning: data)
            timeoutTask.cancel()
        }
        
        /// 超时检测
        self.queue.asyncAfter(deadline: .now() + .seconds(5), execute: timeoutTask)
    }
    
    private func removeComplete(id: UInt16) {
        self.completes.removeValue(forKey: id)
    }
    
    public func resolve(_ domain: String) async throws -> Data {
        let pkt = PKDNSPacket(query: domain, type: .A)
        return try await self.resolve(pkt)
    }
    
    public func resolve(_ packet: PKDNSPacket) async throws -> Data {
        let data = packet.encode()
        return try await self.resolve(data)
    }
    
    public func resolve(_ data: Data) async throws -> Data {
        let id = UInt16(data[data.startIndex ..< data.startIndex+2])
        
        guard let connection = self.connection else {
            throw PKStringError(msg: "not connection")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            
            connection.send(content: data, completion: .contentProcessed({ error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                Task {
                    await self.didWritten(id: id, continuation: continuation)
                }
            }))
        }
    }

}
