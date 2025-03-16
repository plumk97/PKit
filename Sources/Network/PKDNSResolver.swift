//
//  PKDNSResolver.swift
//  PKit
//
//  Created by Plumk on 2025/3/5.
//

import Foundation
import PKCore
import NIO

public actor PKDNSResolver {
   
    public static let shared = PKDNSResolver()
    
    private var servers: [String] = []
    private var channel: Channel?
    private var completes = [UInt16: PKValueCallback<Data>]()
    
    public func bind(servers: [String], group: EventLoopGroup) async throws {
        self.servers = servers
        let bootstrap = DatagramBootstrap(group: group)
            .channelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .channelInitializer { channel in
                channel.pipeline.addHandler(PKDNSResolverHandler(onReceived: { data in
                    Task {
                        await self.handleReceivedData(data)
                    }
                }))
            }
        
        let channel = try await bootstrap.bind(host: "0.0.0.0", port: 0).get()
        self.channel = channel
        
        channel.closeFuture.whenComplete { _ in
            Task {
                await self.rebind()
            }
        }
    }
    
    
    private func rebind() async {
        while true {
            do {
                if let channel = self.channel {
                    try await self.bind(servers: self.servers, group: channel.eventLoop)
                }
                return
            } catch {
                print(error)
            }
        }
    }
    
    private func handleReceivedData(_ data: Data) {
        let id = UInt16(data[data.startIndex ..< data.startIndex+2])
        if let complete = self.completes.removeValue(forKey: id) {
            complete(data)
        }
    }
    
    private func didWritten(id: UInt16, continuation: CheckedContinuation<Data, Error>) {
        guard let channel = self.channel else {
            return
        }
        
        let task = channel.eventLoop.scheduleTask(in: .seconds(5)) {
            Task {
                await self.removeComplete(id: id)
                continuation.resume(throwing: PKStringError(msg: "timeout"))
            }
        }
        
        self.completes[id] = { data in
            task.cancel()
            continuation.resume(returning: data)
        }
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
        
        guard let server = self.servers.randomElement() else {
            throw PKStringError(msg: "no dns server")
        }
        
        guard let channel = self.channel else {
            throw PKStringError(msg: "no dns channel")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            
            do {
                let address = try SocketAddress(ipAddress: server, port: 53)
                let envelope = AddressedEnvelope<ByteBuffer>(remoteAddress: address, data: channel.allocator.buffer(bytes: data))
                
                self.channel?.writeAndFlush(envelope).whenComplete({ result in
                    switch result {
                    case .success:
                        Task {
                            await self.didWritten(id: id, continuation: continuation)
                        }
                        
                    case .failure(let failure):
                        continuation.resume(throwing: failure)
                    }
                })
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

}
