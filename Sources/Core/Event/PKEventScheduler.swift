//
//  PKEventScheduler.swift
//  PKit
//
//  Created by Plumk on 2021/11/3.
//  Copyright © 2021 Plumk. All rights reserved.
//

import Foundation


public class PKEventScheduler {
    public typealias Callback<T> = (T) -> Void
    
    private static let shared = PKEventScheduler()
    private init() {}
    
    /// 保存注册信息
    fileprivate var registerObjects = [Int: WeakObjectSet]()
    
    
    /// 注册事件 相同的对象注册同一个事件 只有第一个会生效
    /// - Parameter obj: 注册对象
    /// - Parameter event: 注册的事件
    /// - Parameter callback: 事件回调
    public static func register<T: PKEventDefine>(_ obj: AnyObject, event: T, callback: Callback<T.Params?>?) {
        guard let callback = callback else {
            return
        }
        
        let objSet: WeakObjectSet
        if let x = self.shared.registerObjects[event.hashValue] {
            objSet = x
        } else {
            objSet = WeakObjectSet()
            self.shared.registerObjects[event.hashValue] = objSet
        }

        guard !objSet.objects.contains(where: { $0.obj === obj }) else {
            /// 已经注册过
            return
        }
        
        let weakObj = WeakObject()
        weakObj.obj = obj
        weakObj.callback = callback
        
        objSet.objects.append(weakObj)
    }
    
    
    
    /// 提取已经注册的事件
    /// - Parameter hashValue:
    /// - Returns:
    fileprivate static func fetchObjects(_ hashValue: Int) -> [WeakObject]? {
        guard let objSet = self.shared.registerObjects[hashValue] else {
            return nil
        }
        
        var releaseIndexs = [Int]()
        var weakObjects = [WeakObject]()
        
        /// 挑选当前有效的对象
        for (idx, weakObj) in objSet.objects.enumerated() {
            if weakObj.obj == nil {
                releaseIndexs.append(idx)
            } else {
                weakObjects.append(weakObj)
            }
        }
        
        /// 移除已经释放的对象
        for i in releaseIndexs.reversed() {
            objSet.objects.remove(at: i)
        }
        
        
        return weakObjects
    }
}


// MARK: - WeakObject
extension PKEventScheduler {
    
    /// 弱引用外部对象
    fileprivate class WeakObject {
        
        /// 注册对象
        weak var obj: AnyObject?
        
        /// 事件执行回调
        var callback: Any?
    }
}

// MARK: - ObjectSet
extension PKEventScheduler {
    
    /// 引用Array 防止地址改变
    fileprivate class WeakObjectSet {
        var objects = [WeakObject]()
    }
}




// MARK: - PKEventDefine 事件定义协议

public protocol PKEventDefine {
    
    /// 事件参数
    associatedtype Params
    
    /// 事件哈希值 用于注册
    var hashValue: Int { get }
}

extension PKEventDefine {
    
    /// 调用事件
    /// - Parameter params:
    public func call(_ params: Params? = nil) {
        
        guard let objects = PKEventScheduler.fetchObjects(self.hashValue) else {
            return
        }
        
        for object in objects {
            
            /// 转换为callback 调用
            if let callback = object.callback as? PKEventScheduler.Callback<Params?> {
                callback(params)
            }
        }
    }
}

