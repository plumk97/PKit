//
//  PKWebServer+HTTPResponse.swift
//  
//
//  Created by Plumk on 2022/9/6.
//

import Foundation
import NIOCore
import NIOHTTP1


extension PKWebServer {
    
    public class HTTPResponse {
        
        /// 当前请求环境
        let context: ChannelHandlerContext
        
        /// 响应状态
        public var status: HTTPResponseStatus = .ok
        
        /// 响应头
        public var headers = [String: String]()
        
        /// 响应数据
        public var body: Data?
        
        /// 响应文件
        public var file: FileHandle?
        
        
        init(ctx: ChannelHandlerContext) {
            self.context = ctx
        }
        
        
        /// 响应纯文本
        /// - Parameter text:
        public func responseText(_ text: String) {
            self.status = .ok
            self.headers["Content-Type"] = "\(PKMIMEType["txt"]); charset=utf-8"
            self.body = text.data(using: .utf8)
            self.response()
        }
        
        /// 响应Json
        /// - Parameter obj:
        public func responseJson(_ obj: Any) throws {
            
            let data = try JSONSerialization.data(withJSONObject: obj, options: .fragmentsAllowed)
            
            self.status = .ok
            self.headers["Content-Type"] = "\(PKMIMEType["json"]); charset=utf-8"
            self.body = data
            self.response()
        }
        
        /// 响应HTML
        /// - Parameter filepath:
        public func responseHTML(_ filepath: String) throws {
            let url = URL(fileURLWithPath: filepath)
            
            self.status = .ok
            self.headers["Content-Type"] = "\(PKMIMEType[url.pathExtension]); charset=utf-8"
            self.body = try Data(contentsOf: url)
            self.response()
        }
        
        /// 响应静态文件
        /// - Parameter filepath:
        public func responseStaticFile(_ filepath: String) {
            
            if filepath.hasSuffix(".html") || filepath.hasSuffix(".htm") {
                try? self.responseHTML(filepath)
                return
            }
            
            let url = URL(fileURLWithPath: filepath)
            
            self.status = .ok
            self.headers["Content-Type"] = "\(PKMIMEType[url.pathExtension]); charset=utf-8"
            if self.headers["Cache-Control"] == nil {
                self.headers["Cache-Control"] = "public, max-age=86400"
            }
            
            self.file = FileHandle(forReadingAtPath: filepath)
            self.response()
        }
        
        
        /// 返回响应
        public func response() {
            
            self.context.eventLoop.next().execute {[weak self] in
             
                guard let self = self else {
                    return
                }
                
                // - 生成headers
                var headers = HTTPHeaders()
                for (key, value) in self.headers {
                    headers.replaceOrAdd(name: key, value: value)
                }
                
                let contentLength: UInt64
                if let body = self.body {
                    contentLength = UInt64(body.count)
                } else if let file = self.file {
                    contentLength = file.seekToEndOfFile()
                    file.seek(toFileOffset: 0)
                } else {
                    contentLength = 0
                }
                
                if contentLength > 0 {
                    headers.replaceOrAdd(name: "Content-Length", value: "\(contentLength)")
                }
                
                // - 生成head
                let head = HTTPResponseHead(version: .http1_1, status: self.status, headers: headers)
                
                // - 写入head
                self.context.write(NIOAny(HTTPServerResponsePart.head(head)), promise: nil)
                
                // - 写入body
                if let body = self.body {
                    self.context.write(NIOAny(HTTPServerResponsePart.body(.byteBuffer(.init(bytes: body)))), promise: nil)
                    
                    self.context.writeAndFlush(NIOAny(HTTPServerResponsePart.end(nil))).whenComplete {[weak self] _ in
                        self?.context.close(promise: nil)
                    }
                    
                } else if let file = self.file {
                    self.responseFile(file)
                    
                } else {
                    self.context.writeAndFlush(NIOAny(HTTPServerResponsePart.end(nil))).whenComplete {[weak self] _ in
                        self?.context.close(promise: nil)
                    }
                    
                }
                
            }
        }
        
        /// 处理文件流
        /// - Parameter file:
        private func responseFile(_ file: FileHandle) {
            
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
                
                guard let self = self else {
                    return
                }
                
                switch ret {
                case .success:
                    self.responseFile(file)
                    
                case .failure:
                    self.context.close(promise: nil)
                }
                
            }
        }
        
    }
    
}
