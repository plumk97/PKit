//
//  PKDefine.swift
//  PKit
//
//  Created by Plumk on 2021/12/17.
//

import Foundation

/// 无参数回调
public typealias PKVoidCallback = @Sendable () -> Void

/// 一个参数回调
public typealias PKValueCallback<A> = @Sendable (A) -> Void

/// 两个参数回调
public typealias PKValue2Callback<A, B> = @Sendable (A, B) -> Void

/// 三个参数回调
public typealias PKValue3Callback<A, B, C> = @Sendable (A, B, C) -> Void
