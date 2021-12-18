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
        
        public let context: ChannelHandlerContext
        public let head: HTTPRequestHead
        
        public let contentLength: Int
        
        public private(set) var body = [UInt8]()
        public private(set) var query = [String: String]()
        
        init(ctx: ChannelHandlerContext, head: HTTPRequestHead) {
            self.context = ctx
            self.head = head
            
            self.contentLength = Int(head.headers.first(name: "Content-Length") ?? "0") ?? 0
            self.parseQuery()
        }
        
        
        private func exec(_ callback: @escaping PKVoidCallback) {
            self.context.eventLoop.next().execute(callback)
        }
        
        private func parseQuery() {
            let coms = self.head.uri.components(separatedBy: "?")
            
            var dict = [String: String]()
            if coms.count > 1 {
                let querys = coms[1].components(separatedBy: "&")
                
                for query in querys {
                    let coms = query.components(separatedBy: "=")
                    guard coms.count > 1 else {
                        continue
                    }
                    
                    let key = coms[0]
                    let value = coms[1]
                    dict[key] = value.removingPercentEncoding
                }
            }
            
            self.query = dict
        }
        
        
        // MARK: - request
        func handleRequestBody(_ data: [UInt8]) {
            self.body.append(contentsOf: data)
        }
        
        func handleRequestEnd() {
            
        }
        
        // MARK: - Response
        public func responseText(_ text: String) {
            self.response(status: .ok, headers: [
                "Content-Type": "text/plain"
            ], data: text.data(using: .utf8))
        }
        
        public func responseJson(_ obj: Any) {
            
            guard let data = try? JSONSerialization.data(withJSONObject: obj, options: .fragmentsAllowed) else {
                self.response(status: .internalServerError)
                return
            }
            self.response(status: .ok, headers: [
                "Content-Type": "application/json"
            ], data: data)
        }
        
        public func responseHTML(_ filepath: String) {
            let url = URL(fileURLWithPath: filepath)
            
            self.response(status: .ok, headers: [
                "Content-Type": PKMIMEType.createMIMEType(fileExtension: url.pathExtension)
            ], data: try? .init(contentsOf: url))
        }
        
        
        public func responseStaticFile(_ filepath: String) {
            let url = URL(fileURLWithPath: filepath)
                
            self.response(status: .ok, headers: [
                "Content-Type": PKMIMEType.createMIMEType(fileExtension: url.pathExtension),
                "Cache-Control": "public, max-age=86400"
            ], file: .init(forReadingAtPath: filepath))
        }
        
        
        public func response(status: HTTPResponseStatus, headers: [String: String]? = nil, data: Data? = nil, file: FileHandle? = nil) {
            
            self.exec {[weak self] in
                guard let unself = self else {
                    return
                }
                
                var hs = HTTPHeaders()
                if let headers = headers {
                    for (key, value) in headers {
                        hs.replaceOrAdd(name: key, value: value)
                    }
                }
                
                let contentLength: UInt64
                if let data = data {
                    contentLength = UInt64(data.count)
                } else if let file = file {
                    contentLength = file.seekToEndOfFile()
                    file.seek(toFileOffset: 0)
                } else {
                    contentLength = 0
                }
                
                if contentLength > 0 {
                    hs.replaceOrAdd(name: "Content-Length", value: "\(contentLength)")
                }
                
                let head = HTTPResponseHead(version: .http1_1,
                                            status: status,
                                            headers: hs)
                
                unself.context.write(NIOAny(HTTPServerResponsePart.head(head)), promise: nil)
                
                if let data = data {
                    unself.context.write(NIOAny(HTTPServerResponsePart.body(.byteBuffer(.init(bytes: data)))), promise: nil)
                    
                    unself.context.writeAndFlush(NIOAny(HTTPServerResponsePart.end(nil))).whenComplete { _ in
                        self?.context.close(promise: nil)
                    }
                    
                } else if let file = file {
                    unself.responseFilePart(file)
                    
                } else {
                    unself.context.writeAndFlush(NIOAny(HTTPServerResponsePart.end(nil))).whenComplete { _ in
                        self?.context.close(promise: nil)
                    }
                }
                
                
            }
        }
        
        
        private func responseFilePart(_ file: FileHandle) {
            
            /// 每次发送20M
            let data = file.readData(ofLength: 20 * 1024 * 1024)
            if data.count <= 0 {
                file.closeFile()
                self.context.writeAndFlush(NIOAny(HTTPServerResponsePart.end(nil))).whenComplete {[weak self] _ in
                    self?.context.close(promise: nil)
                }
                return
            }
            
            self.context.writeAndFlush(NIOAny(HTTPServerResponsePart.body(.byteBuffer(.init(bytes: data))))).whenComplete {[weak self] ret in
                
                guard let unself = self else {
                    return
                }
                switch ret {
                case .success:
                    unself.responseFilePart(file)
                    
                case .failure:
                    unself.context.close(promise: nil)
                }
                
            }
        }
    }
}
