//
//  PKHTTPContext.swift
//  
//
//  Created by Plumk on 2022/12/22.
//

import Foundation
import NIO
import NIOHTTP1
import PKCore

public class PKHTTPContext {
    
    /// 当前请求体
    public let request: PKHTTPRequest
    
    /// 当前请求响应体
    public let response: PKHTTPResponse
    
    init(ctx: ChannelHandlerContext, head: HTTPRequestHead) {
        self.request = PKHTTPRequest(head: head)
        self.response = PKHTTPResponse(ctx: ctx)
    }
}
