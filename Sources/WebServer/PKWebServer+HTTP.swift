//
//  PKWebServer+HTTP.swift
//  PKit
//
//  Created by Plumk on 2021/12/16.
//  Copyright © 2021 Plumk. All rights reserved.
//

import Foundation
import NIO
import NIOHTTP1
import PKCore

extension PKWebServer {
    
    class HTTPHandler: ChannelInboundHandler, RemovableChannelHandler {
        typealias InboundIn = HTTPServerRequestPart
        typealias OutboundOut = HTTPServerResponsePart
        
        var ctx: HTTPContext?
        var callback: HTTPReqeustCallback?
        
        func channelInactive(context: ChannelHandlerContext) {
            self.ctx = nil
        }
        func channelRead(context: ChannelHandlerContext, data: NIOAny) {
            let request = self.unwrapInboundIn(data)
            
            switch request {
            case let .head(head):
                let uriComs = head.uri.components(separatedBy: "?")
                let path = uriComs[0].removingPercentEncoding ?? uriComs[0]
                
                PKLog.log(path)
                
                let ctx = HTTPContext.init(ctx: context, head: head)
                self.ctx = ctx
                
                var callback: HTTPReqeustCallback?
                switch head.method {
                case .GET:
                    callback = PKWebServer.shared.GETs[path]
                    
                case .POST:
                    callback = PKWebServer.shared.POSTs[path]
                    
                default:
                    break
                }
                
                if ctx.contentLength > 1024 * 1024 * 20 {
                    PKLog.log("携带数据不得超出20M")
                    ctx.response(status: .notAcceptable)
                    return
                }
                
                /// 先处理接口
                if let callback = callback {
                    self.callback = callback
                    return
                }
                
                /// - 处理静态文件
                let coms = path.components(separatedBy: "/")
                
                var i = 0
                var parent = ""
                while i < coms.count - 1 {
                    if parent.hasSuffix("/") {
                        parent += coms[i]
                    } else {
                        parent += "/" + coms[i]
                    }
                    
                    if let directory = PKWebServer.shared.StaticFiles[parent] {
                        
                        let absolutePath = directory + coms[(i+1)...].joined(separator: "/")
                        var isDirectory: ObjCBool = .init(false)
                        let isExist = FileManager.default.fileExists(atPath: absolutePath, isDirectory: &isDirectory)
                        if isExist && !isDirectory.boolValue {
                            ctx.responseStaticFile(absolutePath)
                            return
                        }
                        
                    }
                    
                    i += 1
                }

                PKLog.log("notFound", path)
                ctx.response(status: .notFound)
                
                
            case var .body(buffer):
                guard let ctx = ctx else {
                    return
                }

                guard let bytes = buffer.readBytes(length: buffer.readableBytes) else {
                    ctx.response(status: .internalServerError)
                    return
                }
                ctx.handleRequestBody(bytes)
                
            case .end:
                self.ctx?.handleRequestEnd()
                if let callback = callback, let ctx = self.ctx {
                    callback(ctx)
                }

            }
            
            
            
        }
        
    }
}
