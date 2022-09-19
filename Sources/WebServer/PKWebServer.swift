//
//  PKWebServer.swift
//  PKit
//
//  Created by Plumk on 2021/12/15.
//  Copyright © 2021 Plumk. All rights reserved.
//

import Foundation
import PKCore
import NIO
import NIOHTTP1
import NIOWebSocket

public class PKWebServer {
    
    public typealias HTTPReqeustCallback = PKValueCallback<HTTPContext>
    public typealias WebSocketReceivedCallback = PKValueCallback<WebSocketContext>
    
    /// 使用线程数量
    public static var numberOfThreads = System.coreCount
    
    static let shared = PKWebServer()
    
    ///
    private lazy var bootstrap: ServerBootstrap = self.createBootstrap()
    
    /// - HTTP 频道
    private var httpChannel: Channel?
    
    /// 静态文件
    private(set) var StaticFiles = [String: String]()
    
    /// GET接口
    private(set) var GETs = [String: HTTPReqeustCallback]()
    
    /// POST接口
    private(set) var POSTs = [String: HTTPReqeustCallback]()
    
    /// websocket 接受连接回调
    private(set) var webSocketReceivedCallback: WebSocketReceivedCallback?
    
    private init() {
        
    }
    
    private func createBootstrap() -> ServerBootstrap {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: PKWebServer.numberOfThreads)
        
        let upgrader = NIOWebSocketServerUpgrader { channel, head in
            channel.eventLoop.makeSucceededFuture(HTTPHeaders())
            
        } upgradePipelineHandler: { channel, head in
            channel.pipeline.addHandler(WebSocketHandler(head: head))
        }
        
        let bootstrap = ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelInitializer({ channel in
                
                let httpHandler = HTTPHandler()
                
                let config: NIOHTTPServerUpgradeConfiguration = (
                    upgraders: [ upgrader ],
                    completionHandler: { _ in
                        channel.pipeline.removeHandler(httpHandler, promise: nil)
                    }
                )
                
                return channel.pipeline.configureHTTPServerPipeline(withServerUpgrade: config).flatMap({
                    channel.pipeline.addHandler(httpHandler)
                })
            })
        
        return bootstrap
    }
    
    private func run(port: Int) throws -> Bool {
        self.httpChannel = try self.bootstrap.bind(host: "0.0.0.0", port: port).wait()
        return true
    }
    
    @discardableResult
    public static func run(port: Int = 8080) throws -> Bool {
        return try self.shared.run(port: port)
    }
    
    public static func stop() {
        self.shared.httpChannel?.close(mode: .all, promise: nil)
    }
}


// MARK: - Register
extension PKWebServer {
    
    public static func StaticFile(_ path: String, directory: String) {
        if directory.hasSuffix("/") {
            self.shared.StaticFiles[path] = directory
        } else {
            self.shared.StaticFiles[path] = directory + "/"
        }
    }
    
    public static func GET(_ path: String, callback: @escaping HTTPReqeustCallback) {
        self.shared.GETs[path] = callback
    }
    
    public static func POST(_ path: String, callback: @escaping HTTPReqeustCallback) {
        self.shared.POSTs[path] = callback
    }
}


// MARK: - Websocket
extension PKWebServer {
    
    public static func setWebSocketReceivedCallback(_ callback: @escaping WebSocketReceivedCallback) {
        self.shared.webSocketReceivedCallback = callback
    }
}
