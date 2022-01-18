//
//  PKEventScheduler.swift
//  PKit
//
//  Created by Plumk on 2021/11/3.
//  Copyright © 2021 Plumk. All rights reserved.
//

import Foundation


public class PKEventScheduler {
    
    public typealias Callback<T> = (T, AnyObject?) -> Void
    
    private static let shared = PKEventScheduler()
    private init() {}
    
    
    /// 按事件分类接收者
    fileprivate var receiverClassDict = [Int: ReceiverSet]()
    
    
    /// 注册事件 相同的对象注册同一个事件 只有第一个会生效
    /// - Parameter obj: 注册对象
    /// - Parameter event: 注册的事件
    /// - Parameter callback: 事件回调
    @discardableResult
    public static func register<T: PKEventDefine>(_ obj: AnyObject, event: T, queue: DispatchQueue? = nil, callback: Callback<T.Params?>?) -> PKEventReceiver? {
        guard let callback = callback else {
            return nil
        }
        
        let receiverSet: ReceiverSet
        if let x = self.shared.receiverClassDict[event.hashValue] {
            receiverSet = x
        } else {
            receiverSet = ReceiverSet()
            self.shared.receiverClassDict[event.hashValue] = receiverSet
        }

        if let idx = receiverSet.receivers.firstIndex(where: { $0.obj === obj}) {
            /// 已经注册过
            return receiverSet.receivers[idx]
        }
        
        let receiver = PKEventReceiver()
        receiver.obj = obj
        receiver.callback = callback
        receiver.queue = queue
        
        receiverSet.receivers.append(receiver)
        return receiver
    }
    
    /// 取消注册事件
    /// - Parameter receiver:
    public static func unregister(_ receiver: PKEventReceiver?) {
        guard let receiver = receiver else {
            return
        }

        self.shared.receiverClassDict.forEach({
            if let idx = $0.value.receivers.firstIndex(where: { $0.obj === receiver.obj }) {
                $0.value.receivers.remove(at: idx)
            }
        })
        
    }
    
    
    /// 提取事件对应的接收者
    /// - Parameter hashValue: 事件hash值
    /// - Returns:
    static func fetchReceivers(_ hashValue: Int) -> [PKEventReceiver]? {
        
        guard let receiverSet = self.shared.receiverClassDict[hashValue] else {
            return nil
        }
        /// 过滤无效的接收者
        let receivers = receiverSet.receivers.filter({ $0.isValid })
        receiverSet.receivers = receivers
        
        /// 无接收者清理分类
        if receivers.count <= 0 {
            self.shared.receiverClassDict.removeValue(forKey: hashValue)
        }
        
        return receivers
    }
}

// MARK: - ObjectSet
extension PKEventScheduler {
    
    /// 引用Array 防止地址改变
    fileprivate class ReceiverSet {
        var receivers = [PKEventReceiver]()
    }
}
