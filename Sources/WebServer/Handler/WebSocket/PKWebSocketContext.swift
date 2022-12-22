//
//  PKWebSocketContext.swift
//  
//
//  Created by Plumk on 2022/12/22.
//

import Foundation
import NIO
import NIOHTTP1
import NIOWebSocket

public class PKWebSocketContext {
    
    public typealias CaughtErrorCallback = (PKWebSocketContext, Error) -> Void
    public typealias DisconnectedCallback = (PKWebSocketContext) -> Void
    public typealias ReceivedTextCallback = (PKWebSocketContext, String) -> Void
    public typealias ReceivedDataCallback = (PKWebSocketContext, [UInt8]) -> Void
    
    public let head: HTTPRequestHead
    public let ctx: ChannelHandlerContext
    
    public var caughtErrorCallback: CaughtErrorCallback?
    public var disconnectedCallback: DisconnectedCallback?
    public var receivedTextCallback: ReceivedTextCallback?
    public var receivedDataCallback: ReceivedDataCallback?
    
    let remoteAddress: SocketAddress?
    
    init(head: HTTPRequestHead, ctx: ChannelHandlerContext) {
        self.head = head
        self.ctx = ctx
        self.remoteAddress = ctx.remoteAddress
    }
    
    public func sendText(_ text: String) {
        self.ctx.eventLoop.next().execute {[weak self] in
            guard let unself = self else {
                return
            }
            
            let buffer = unself.ctx.channel.allocator.buffer(string: text)
            let frame = WebSocketFrame.init(fin: true, opcode: .text, data: buffer)
            unself.ctx.writeAndFlush(NIOAny(frame), promise: nil)
        }
    }
    
    public func sendData<Bytes: Sequence>(_ data: Bytes) where Bytes.Element == UInt8 {
        self.ctx.eventLoop.next().execute {[weak self] in
            guard let unself = self else {
                return
            }
            
            let buffer = unself.ctx.channel.allocator.buffer(bytes: data)
            let frame = WebSocketFrame.init(fin: true, opcode: .binary, data: buffer)
            unself.ctx.writeAndFlush(NIOAny(frame), promise: nil)
        }
    }
}

// MARK: - Hashable
extension PKWebSocketContext: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.remoteAddress)
    }
    
    public static func == (lhs: PKWebSocketContext, rhs: PKWebSocketContext) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
