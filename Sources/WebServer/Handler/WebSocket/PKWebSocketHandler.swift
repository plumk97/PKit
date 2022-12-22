//
//  PKWebSocketHandler.swift
//  
//
//  Created by Plumk on 2022/12/22.
//

import Foundation
import PKCore
import NIO
import NIOHTTP1
import NIOWebSocket

class PKWebSocketHandler: ChannelInboundHandler, RemovableChannelHandler {
    typealias InboundIn = WebSocketFrame
    typealias OutboundOut = WebSocketFrame
    
    
    let head: HTTPRequestHead
    var initedCallback: PKValueCallback<PKWebSocketContext>?
    
    var ctx: PKWebSocketContext?
    
    init(head: HTTPRequestHead, initedCallback: PKValueCallback<PKWebSocketContext>?) {
        self.head = head
        self.initedCallback = initedCallback
    }
    
    // MARK: - ChannelInboundHandler, RemovableChannelHandler
    func handlerAdded(context: ChannelHandlerContext) {
        let ctx = PKWebSocketContext.init(head: self.head, ctx: context)
        self.ctx = ctx
        self.initedCallback?(ctx)
    }

    func handlerRemoved(context: ChannelHandlerContext) {
        if let ctx = ctx {
            ctx.disconnectedCallback?(ctx)
        }
        self.ctx = nil
    }
    
    func errorCaught(context: ChannelHandlerContext, error: Error) {
        if let ctx = ctx {
            ctx.caughtErrorCallback?(ctx, error)
        }
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let frame = self.unwrapInboundIn(data)
        
        switch frame.opcode {
        case .connectionClose:
            self.receivedClose(context: context, frame: frame)
        case .ping:
            self.pong(context: context, frame: frame)
            
        case .text:
            var data = frame.unmaskedData
            let text = data.readString(length: data.readableBytes) ?? ""
            if let ctx = ctx {
                ctx.receivedTextCallback?(ctx, text)
            }
            
        case .binary:
            var data = frame.unmaskedData
            guard let bytes = data.readBytes(length: data.readableBytes) else {
                return
            }
            
            if let ctx = ctx {
                ctx.receivedDataCallback?(ctx, bytes)
            }
             
        case .continuation, .pong:
            // We ignore these frames.
            break
            
        default:
            // Unknown frames are errors.
            self.closeOnError(context: context)
        }
    }

    func channelReadComplete(context: ChannelHandlerContext) {
        
    }

    func channelInactive(context: ChannelHandlerContext) {
        
    }
    
    // MARK: - Private
    /// 是否等待关闭中
    private var awaitingClose: Bool = false
    
    private func receivedClose(context: ChannelHandlerContext, frame: WebSocketFrame) {
        // Handle a received close frame. In websockets, we're just going to send the close
        // frame and then close, unless we already sent our own close frame.
        if awaitingClose {
            // Cool, we started the close and were waiting for the user. We're done.
            context.close(promise: nil)
        } else {
            // This is an unsolicited close. We're going to send a response frame and
            // then, when we've sent it, close up shop. We should send back the close code the remote
            // peer sent us, unless they didn't send one at all.
            var data = frame.unmaskedData
            let closeDataCode = data.readSlice(length: 2) ?? ByteBuffer()
            let closeFrame = WebSocketFrame(fin: true, opcode: .connectionClose, data: closeDataCode)
            _ = context.write(self.wrapOutboundOut(closeFrame)).map { () in
                context.close(promise: nil)
            }
        }
    }

    private func pong(context: ChannelHandlerContext, frame: WebSocketFrame) {
        var frameData = frame.data
        let maskingKey = frame.maskKey

        if let maskingKey = maskingKey {
            frameData.webSocketUnmask(maskingKey)
        }

        let responseFrame = WebSocketFrame(fin: true, opcode: .pong, data: frameData)
        context.write(self.wrapOutboundOut(responseFrame), promise: nil)
    }

    private func closeOnError(context: ChannelHandlerContext) {
        // We have hit an error, we want to close. We do that by sending a close frame and then
        // shutting down the write side of the connection.
        var data = context.channel.allocator.buffer(capacity: 2)
        data.write(webSocketErrorCode: .protocolError)
        let frame = WebSocketFrame(fin: true, opcode: .connectionClose, data: data)
        context.write(self.wrapOutboundOut(frame)).whenComplete { (_: Result<Void, Error>) in
            context.close(mode: .output, promise: nil)
        }
        awaitingClose = true
    }
}
