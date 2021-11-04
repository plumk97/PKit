//
//  PLNavigationConfig.swift
//  PKit
//
//  Created by Plumk on 2021/11/4.
//

import Foundation


open class PLNavigationConfig {
    
    /// 是否屏蔽返回手势
    open var isDisablePopGestureRecognizer: Bool = false
    
    /// 返回item图片
    open var backItemImage: UIImage? {
        didSet {
            self.didChangeBackItemCallback?()
        }
    }
    
    /// 设置返回按钮
    open var backItem: UIBarButtonItem? {
        didSet {
            self.didChangeBackItemCallback?()
        }
    }
    
    /// 改变回调
    var didChangeBackItemCallback: (() -> Void)?
}
