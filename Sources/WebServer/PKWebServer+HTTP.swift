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
        
        var beginTime: clock_t!
        
        /// 当前请求环境
        var ctx: HTTPContext?
        
        /// 当前请求接口回调
        var callback: HTTPReqeustCallback?
        
        /// 请求结束
        /// - Parameter context:
        func channelInactive(context: ChannelHandlerContext) {
            let endTime = clock()
            let elapsedTime = (endTime - self.beginTime) / (CLOCKS_PER_SEC / 1000)
            
            if let ctx = ctx {
                PKLog.log(ctx.response.status.code, ctx.response.status.reasonPhrase, ctx.request.head.uri, "\(elapsedTime)ms")
            }
            
            self.ctx = nil
        }
        
        /// 请求开始
        /// - Parameter context:
        func channelActive(context: ChannelHandlerContext) {
            self.beginTime = clock()
        }
        
        /// 接受数据
        /// - Parameters:
        ///   - context:
        ///   - data:
        func channelRead(context: ChannelHandlerContext, data: NIOAny) {
            let request = self.unwrapInboundIn(data)
            
            switch request {
            case let .head(head):
                let uriComs = head.uri.components(separatedBy: "?")
                let path = uriComs[0].removingPercentEncoding ?? uriComs[0]
                
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
                
                if ctx.request.contentLength > 1024 * 1024 * 20 {
                    PKLog.log("携带数据不得超出20M")
                    ctx.response.status = .notAcceptable
                    ctx.response.response()
                    return
                }
                
                /// 先处理接口
                if let callback = callback {
                    self.callback = callback
                    return
                }
                
                
                if !self.handleStaticFiles(path: path, ctx: ctx) {
                    ctx.response.status = .notFound
                    ctx.response.response()
                }
                
            case var .body(buffer):
                guard let ctx = ctx else {
                    return
                }

                guard let bytes = buffer.readBytes(length: buffer.readableBytes) else {
                    ctx.response.status = .internalServerError
                    ctx.response.response()
                    return
                }
                ctx.request.appendBody(bytes)
                
            case .end:
                ctx?.request.requestEnd()
                
                if let callback = callback, let ctx = self.ctx {
                    callback(ctx)
                }

            }
        }
        
        /// 处理静态文件
        /// - Parameter path:
        func handleStaticFiles(path: String, ctx: HTTPContext) -> Bool {
            
            var path = path
            
            if path == "/" {
                path = "/index.html"
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
                        ctx.response.responseStaticFile(absolutePath)
                        return true
                    }
                }
                
                i += 1
            }
            
            return false
        }
    }
}
