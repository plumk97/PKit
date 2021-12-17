//
//  PKEvent.swift
//  PKit
//
//  Created by Plumk on 2021/11/3.
//  Copyright © 2021 Plumk. All rights reserved.
//

import Foundation

public struct PKEvent<_Params>: PKEventDefine, Hashable {
    public typealias Params = _Params
    
    private let identifier: String
    
    /// 初始化
    /// - Parameter identifier: 事件标识 需要唯一
    public init(identifier: String) {
        self.identifier = identifier
    }
    
    
    /// 初始化
    /// - Parameters:
    ///   - cls: 一般传当前类
    ///   - name: 事件名
    public init(cls: AnyClass, name: String) {
        self.init(identifier: (cls.description() + name))
    }
    
    // MARK: - Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }
}
