//
//  PKDefine.swift
//  PKit
//
//  Created by Plumk on 2021/12/17.
//

import Foundation

/// 无参数回调
public typealias PKVoidCallback = () -> Void

/// 一个参数回调
public typealias PKValueCallback<A> = (A) -> Void

/// 两个参数回调
public typealias PKValue2Callback<A, B> = (A, B) -> Void

/// 三个参数回调
public typealias PKValue3Callback<A, B, C> = (A, B, C) -> Void
