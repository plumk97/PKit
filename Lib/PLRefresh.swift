//
//  PLRefresh.swift
//  PLKit
//
//  Created by iOS on 2019/4/26.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

typealias PLRefreshHandleCallback = ()->Void

protocol PLRefreshWidgetable: UIView {
    
    /// 刷新回调
    var handleCallback: PLRefreshHandleCallback? { get set }
    
    /// 刷新进度
    ///
    /// - Parameter progress: 0-1
    func refreshProgress(_ progress: CGFloat)
    
    /// 开始刷新
    func beginRefreshing()
    
    /// 结束刷新
    func endRefreshing()
}

class PLRefresh: NSObject {
    
    weak var scrollView: UIScrollView?
    
    /// 是否排斥其它刷新 当其中一个正在刷新时 其他刷新不生效
    var isExclusiveRefresh: Bool = true
    
    /// 是否自动控制safe area
    var isEnableSafeArea: Bool = true
    
    /// 刷新高度
    var refreshHeight: CGFloat = 64
    
    /// 下拉刷新 顶部控件
    var top: PLRefreshWidgetable? {
        didSet {
            oldValue?.removeFromSuperview()
            if let untop = top {
                self.scrollView?.addSubview(untop)
            }
            self.relayout()
        }
    }
    
    private var safeArea: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            guard let window = UIApplication.shared.delegate?.window else {
                return .zero
            }
            return window?.safeAreaInsets ?? .zero
        }
        return .zero
    }
    
    /// scrollView 上一次ContentSize
    private var preContentSize: CGSize = .zero
    /// scrollView 上一次Bounds
    private var preBounds: CGRect = .zero
    /// scrollView 上一次ContentInset
    private var preContentInset: UIEdgeInsets = .zero
    
    /// 增加的 ContentInset
    private var appendContentInset: UIEdgeInsets = .zero
    
    /// 真实的 ContentInset 去掉 appendContentInset
    private var scrollViewRealContentInset: UIEdgeInsets {
        var contentInset = self.scrollView?.contentInset ?? .zero
        contentInset.left -= appendContentInset.left
        contentInset.top -= appendContentInset.top
        contentInset.right -= appendContentInset.right
        contentInset.bottom -= appendContentInset.bottom
        return contentInset
    }
    
    init(scrollView: UIScrollView) {
        super.init()
        self.scrollView = scrollView
        
        let observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault()?.takeUnretainedValue(), CFRunLoopActivity.allActivities.rawValue, true, 0) { (observer, activity) in
            if activity.rawValue == CFRunLoopActivity.beforeWaiting.rawValue {
                guard let scrollView = self.scrollView else {
                    return
                }
                self.updateOffset()
                
                var relayout = false
                
                if !self.preContentSize.equalTo(scrollView.contentSize) {
                    self.preContentSize = scrollView.contentSize
                    relayout = true
                }
                
                if !self.preBounds.equalTo(scrollView.bounds) {
                    self.preBounds = scrollView.bounds
                    relayout = true
                }
                
                if !self.preContentInset.equalTo(self.scrollViewRealContentInset) {
                    self.preContentInset = self.scrollViewRealContentInset
                    relayout = true
                }
                
                if relayout {
                    self.relayout()
                }
                
            }
        }
        CFRunLoopAddObserver(CFRunLoopGetMain(), observer, CFRunLoopMode.commonModes)
    }

    
    fileprivate func relayout() {
        
        guard let scrollView = self.scrollView else {
            return
        }
        
        if let top = self.top {
            top.frame.size = .init(width: scrollView.frame.width, height: top.frame.height)
            top.frame.origin = .init(x: 0, y: -top.frame.height)
        }
    }
    
    // -- KVO
    fileprivate func updateOffset() {
        let contentOffset = self.scrollView?.contentOffset ?? .zero
        let isTouching = self.scrollView?.isDragging ?? false
        guard isTouching else {
            return
        }
        print(contentOffset.y)
    }
}

extension UIEdgeInsets {
    func equalTo(_ insets: UIEdgeInsets) -> Bool {
        return self.top == insets.top && self.left == insets.left && self.right == insets.right && self.bottom == insets.bottom
    }
}


fileprivate var kPLRefresh = "PLRefresh"
extension PL where Base: UIScrollView {
    var refresh: PLRefresh {
        
        var obj = objc_getAssociatedObject(self.base, &kPLRefresh) as? PLRefresh
        if obj == nil {
            obj = PLRefresh.init(scrollView: self.base)
            objc_setAssociatedObject(self.base, &kPLRefresh, obj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return obj!
    }
}
