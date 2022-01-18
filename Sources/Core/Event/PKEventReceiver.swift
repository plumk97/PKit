//
//  PKEventReceiver.swift
//  PKit
//
//  Created by Plumk on 2022/1/18.
//  Copyright © 2021 Plumk. All rights reserved.
//

import Foundation


public class PKEventReceiver {
    
    /// 注册对象
    weak var obj: AnyObject?
    
    /// 事件回调
    var callback: Any?
    
    /// 当前触发次数
    var takeCount = 0
    
    var queue: DispatchQueue?
    
    /// 最大触发次数 <= 0代表不限制
    public private(set) var maxTakeCount = 0
    
    /// 指定触发次数
    /// - Parameter count: <= 0代表不限制
    /// - Returns:
    @discardableResult
    public func take(_ count: Int) -> Self {
        self.maxTakeCount = count
        return self
    }
    
    
    /// 取消注册
    public func unregister() {
        PKEventScheduler.unregister(self)
    }
}


// MARK: - Check
extension PKEventReceiver {
    
    /// 当前接收者是否有效
    var isValid: Bool {
    
        guard self.obj != nil else {
            return false
        }
        
        guard self.maxTakeCount == 0 || self.takeCount < self.maxTakeCount else {
            return false
        }
        
        return true
    }
}
