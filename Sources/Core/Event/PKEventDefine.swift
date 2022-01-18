//
//  PKEventDefine.swift
//  PKit
//
//  Created by Plumk on 2022/1/18.
//  Copyright © 2021 Plumk. All rights reserved.
//

import Foundation

/// 事件定义协议
public protocol PKEventDefine {
    
    /// 事件参数
    associatedtype Params
    
    /// 事件哈希值 用于注册
    var hashValue: Int { get }
}

extension PKEventDefine {
    
    
    /// 调用事件
    /// - Parameters:
    ///   - params: 事件参数
    ///   - object: 指定发送对象
    public func call(_ params: Params? = nil, object: AnyObject? = nil) {
       
        guard let receivers = PKEventScheduler.fetchReceivers(self.hashValue) else {
            return
        }
        
        /// 调用事件回调
        receivers.forEach({
            
            $0.takeCount += 1
            if let callback = $0.callback as? PKEventScheduler.Callback<Params?> {
                if let queue = $0.queue {
                    queue.async {
                        callback(params, object)
                    }
                } else {
                    callback(params, object)
                }
                
            }
        })
        
    }
}

