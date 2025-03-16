//
//  PKDNSResolverHandler.swift
//  PKit
//
//  Created by Plumk on 2025/3/16.
//

import Foundation
import NIO
import PKCore

class PKDNSResolverHandler: ChannelInboundHandler {
    typealias InboundIn = AddressedEnvelope<ByteBuffer>
    
    let onReceived: PKValueCallback<Data>?
    init(onReceived: PKValueCallback<Data>?) {
        self.onReceived = onReceived
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let envelope = self.unwrapInboundIn(data)
        var buffer = envelope.data
        guard buffer.readableBytes > 0 else {
            return
        }
        
        if let bytes = buffer.readBytes(length: buffer.readableBytes) {
            self.onReceived?(Data(bytes))
        }
    }
}
