//
//  PKHTTPRequest.swift
//  
//
//  Created by Plumk on 2022/12/22.
//

import Foundation
import NIO
import NIOHTTP1
import PKCore

public class PKHTTPRequest {
    
    /// 请求头
    public let head: HTTPRequestHead
    
    /// 携带内容长度
    public let contentLength: Int
    
    /// 携带内容
    public private(set) var body = [UInt8]()
    
    /// 查询参数
    public private(set) var query = [String: String]()
    
    /// 初始化
    /// - Parameter head: 请求头
    init(head: HTTPRequestHead) {
        self.head = head
        
        self.contentLength = Int(head.headers.first(name: "Content-Length") ?? "0") ?? 0
        self.parseQuery()
    }
    
    /// 解析查询参数
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
    
    /// 添加body数据
    /// - Parameter data:
    func appendBody(_ data: [UInt8]) {
        self.body.append(contentsOf: data)
    }
    
    /// 请求结束
    func requestEnd() {
        
    }
}
