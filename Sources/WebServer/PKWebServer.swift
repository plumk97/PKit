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
    
    public typealias HTTPHandleCallback = PKValueCallback<PKHTTPContext>
    public typealias WebSocketEstablishedCallback = PKValueCallback<PKWebSocketContext>
    
    static let shared = PKWebServer()
    
    /// - HTTP 频道
    private var httpChannel: Channel?
    
    /// 静态文件
    private(set) var StaticFiles = [String: String]()
    
    /// GET接口
    private(set) var GETs = [String: HTTPHandleCallback]()
    
    /// POST接口
    private(set) var POSTs = [String: HTTPHandleCallback]()
    
    /// websocket 接受连接回调
    private(set) var webSocketEstablishedCallback: WebSocketEstablishedCallback?
    
    /// 是否启用webSocket
    private var isEnableWebSocket: Bool {
        return self.webSocketEstablishedCallback != nil
    }
    
    private init() {
        
    }
    
    
    private func createWebSocketUpgrader() -> NIOWebSocketServerUpgrader? {
        
        let upgrader = NIOWebSocketServerUpgrader { channel, head in
            channel.eventLoop.makeSucceededFuture(HTTPHeaders())
            
        } upgradePipelineHandler: { channel, head in
            channel.pipeline.addHandler(PKWebSocketHandler(head: head, initedCallback: self.webSocketEstablishedCallback))
        }
        
        return upgrader
    }
    
    private func createBootstrap(loopGroup: MultiThreadedEventLoopGroup) -> ServerBootstrap {
        
        let upgrader: NIOWebSocketServerUpgrader?
        if self.isEnableWebSocket {
            upgrader = self.createWebSocketUpgrader()
        } else {
            upgrader = nil
        }
        
        let bootstrap = ServerBootstrap(group: loopGroup)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelInitializer({ channel in
                
                let httpHandler = PKHTTPHandler()
                
                if let upgrader = upgrader {
                    let config: NIOHTTPServerUpgradeConfiguration = (
                        upgraders: [ upgrader ],
                        completionHandler: { _ in
                            channel.pipeline.removeHandler(httpHandler, promise: nil)
                        }
                    )
                    
                    return channel.pipeline.configureHTTPServerPipeline(withServerUpgrade: config).flatMap({
                        channel.pipeline.addHandler(httpHandler)
                    })
                } else {
                    return channel.pipeline.configureHTTPServerPipeline().flatMap {
                        channel.pipeline.addHandler(httpHandler)
                    }
                }
                
            })
        
        return bootstrap
    }
    
    private func run(port: Int, loopGroup: MultiThreadedEventLoopGroup = .init(numberOfThreads: System.coreCount)) throws {
        guard self.httpChannel == nil else {
            return
        }
        
        let bootstrap = self.createBootstrap(loopGroup: loopGroup)
        self.httpChannel = try bootstrap.bind(host: "0.0.0.0", port: port).wait()
    }
    
    private func stop() {
        _ = self.httpChannel?.close()
        self.httpChannel = nil
    }

    
}

// MARK: - Static
extension PKWebServer {
    public static func run(port: Int = 8080) throws {
        try self.shared.run(port: port)
    }
    
    public static func stop() {
        self.shared.stop()
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
    
    public static func GET(_ path: String, callback: @escaping HTTPHandleCallback) {
        self.shared.GETs[path] = callback
    }
    
    public static func POST(_ path: String, callback: @escaping HTTPHandleCallback) {
        self.shared.POSTs[path] = callback
    }
    
    public static func WebSocketEstablished(_ callback: @escaping WebSocketEstablishedCallback) {
        self.shared.webSocketEstablishedCallback = callback
    }
}
