//
//  PKWebServer+HTTPContext.swift
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
    
    public class HTTPContext {
        
        /// 当前请求环境
        public let context: ChannelHandlerContext
        
        /// 当前请求体
        public let request: HTTPRequest
        
        /// 当前请求响应体
        public let response: HTTPResponse
        
        init(ctx: ChannelHandlerContext, head: HTTPRequestHead) {
            self.context = ctx
            self.request = HTTPRequest(head: head)
            self.response = HTTPResponse(ctx: ctx)
        }
    }
}
