//
//  PLNavigationConfig.swift
//  PKit
//
//  Created by Plumk on 2021/11/4.
//

import UIKit

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
    
    /// 导航栏高度
    open var navigationBarHeight: CGFloat = 44 {
        didSet {
            self.didChangeBarHeightCallback?()
        }
    }
    
    /// 横屏导航栏高度
    open var landscapeNavigationBarHeight: CGFloat = 0 {
        didSet {
            self.didChangeBarHeightCallback?()
        }
    }
    
    /// 返回按钮改变回调
    var didChangeBackItemCallback: (() -> Void)?
    
    /// 状态栏高度改变回调
    var didChangeBarHeightCallback: (() -> Void)?
    
    init() {
        
        /// 屏幕宽度大于400 横屏导航栏高度为44
        if UIScreen.main.nativeBounds.width / UIScreen.main.nativeScale > 400 {
            self.landscapeNavigationBarHeight = 44
        } else {
            self.landscapeNavigationBarHeight = 32
        }
        
    }
}
