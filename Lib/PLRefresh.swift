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
    
    /// 逐渐透明
    var gradualAlpha: Bool { get set }
    
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

fileprivate enum PLRefreshStatus: Int {
    case normal
    case willBeginRefreshing
    case refreshing
    case willEndRefreshing
}

infix operator < : ComparisonPrecedence
fileprivate func <(left: PLRefreshStatus, right: PLRefreshStatus) -> Bool {
    return left.rawValue < right.rawValue
}

infix operator >= : ComparisonPrecedence
fileprivate func >=(left: PLRefreshStatus, right: PLRefreshStatus) -> Bool {
    return left.rawValue >= right.rawValue
}

class PLRefresh: NSObject {
    
    weak var scrollView: UIScrollView?
    
    /// 刷新高度
    var refreshHeight: CGFloat = 64
    
    /// 下拉刷新 顶部控件
    var top: PLRefreshWidgetable? {
        didSet {
            oldValue?.removeFromSuperview()
            if let unview = top {
                self.scrollView?.addSubview(unview)
            }
            self.relayout()
        }
    }
    /// 上拉加载 底部控件
    var bottom: PLRefreshWidgetable? {
        didSet {
            oldValue?.removeFromSuperview()
            if let unview = bottom {
                self.scrollView?.addSubview(unview)
            }
            self.relayout()
        }
    }
    
    /// scrollView safeAreaInsets
    private var safeArea: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            
            return self.scrollView?.safeAreaInsets ?? .zero
        }
        return .zero
    }
    
    /// scrollView 上一次ContentSize
    private var preContentSize: CGSize = .zero
    /// scrollView 上一次Bounds
    private var preBounds: CGRect = .zero
    /// scrollView 上一次ContentInset
    private var preContentInset: UIEdgeInsets = .zero
    /// scrollView 上一次Offset.y
    private var preOffsetY: CGFloat = 0
    /// 增加的 ContentInset
    private var appendContentInset: UIEdgeInsets = .zero {
        didSet {
            self.reloadAppendContentInsets(oldValue: oldValue)
        }
    }
    
    /// 真实的 ContentInset 去掉 appendContentInset
    private var realContentInset: UIEdgeInsets {
        var contentInset = self.scrollView?.contentInset ?? .zero
        contentInset.left -= appendContentInset.left
        if self.topRefreshStatus >= .refreshing {
            contentInset.top -= appendContentInset.top
        }
        contentInset.right -= appendContentInset.right
        if self.bottomRefreshStatus >= .refreshing {
            contentInset.bottom -= appendContentInset.bottom
        }
        return contentInset
    }
    
    
    /// 增加 inset.top safe.top的offset
    private var offsetMinY: CGFloat {
        var contentOffset = self.scrollView?.contentOffset ?? .zero
        
        let contentInset = self.realContentInset
        contentOffset.y += contentInset.top
        contentOffset.y += self.safeArea.top
        
        return contentOffset.y
    }
    
    /// scrollView 当前bottom
    private var currentBottom: CGFloat {
        var contentSizeHeight = self.scrollView?.contentSize.height ?? 0
        
        let contentInset = self.realContentInset
        contentSizeHeight += contentInset.top
        contentSizeHeight += contentInset.bottom
        
        return contentSizeHeight
    }
    
    /// scrollView 最大bottom
    private var maximumBottom: CGFloat {
        
        let boundsHeight = (self.scrollView?.bounds.height ?? 0) - self.safeArea.bottom - self.safeArea.top
        return max(boundsHeight, self.currentBottom)
    }
    
    /// 记录顶部刷新进度
    private var recordTopProgress: CGFloat = 0
    /// 顶部是否正在刷新
    private var topRefreshStatus: PLRefreshStatus = .normal
    
    /// 记录底部刷新进度
    private var recordBottomProgress: CGFloat = 0
    /// 底部是否正在刷新
    private var bottomRefreshStatus: PLRefreshStatus = .normal
    
    /// --
    private var mainRunLoopObserver: CFRunLoopObserver!
    
    init(scrollView: UIScrollView) {
        super.init()
        self.scrollView = scrollView
        
        self.mainRunLoopObserver = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault()?.takeUnretainedValue(), CFRunLoopActivity.allActivities.rawValue, true, 0) {[unowned self] (observer, activity) in
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
                
                if !self.preBounds.size.equalTo(scrollView.bounds.size) {
                    self.preBounds = scrollView.bounds
                    relayout = true
                }
                
                if !self.preContentInset.equalTo(self.realContentInset) {
                    self.preContentInset = self.realContentInset
                    relayout = true
                }
                
                if relayout {
                    self.relayout()
                }
            }
        }
        CFRunLoopAddObserver(CFRunLoopGetMain(), self.mainRunLoopObserver, CFRunLoopMode.commonModes)
    }
    
    deinit {
        CFRunLoopObserverInvalidate(self.mainRunLoopObserver)
        CFRunLoopRemoveObserver(CFRunLoopGetMain(), self.mainRunLoopObserver, CFRunLoopMode.commonModes)
        self.mainRunLoopObserver = nil
    }

    
    fileprivate func relayout() {
        
        guard let scrollView = self.scrollView else {
            return
        }

        if let top = self.top {
            top.frame.size = .init(width: scrollView.frame.width, height: top.frame.height)
            top.frame.origin = .init(x: 0, y: -top.frame.height - self.realContentInset.top)
        }
        
        if let bottom = self.bottom {
            bottom.frame.size = .init(width: scrollView.frame.width, height: bottom.frame.height)
            
            var y = self.maximumBottom
//            y -= self.realContentInset.top
            
            bottom.frame.origin = .init(x: 0, y: y)
        }
    }
    
    fileprivate func reloadAppendContentInsets(oldValue: UIEdgeInsets) {
        
        /// 进入此方法前 appendContentInset 已经改变
        UIView.animate(withDuration: 0.25, animations: {
            var contentInset = self.realContentInset
            
            // - top
            if self.topRefreshStatus == .willBeginRefreshing {
                contentInset.top += self.appendContentInset.top
                self.topRefreshStatus = .refreshing
                self.top?.beginRefreshing()
            }
            
            if self.topRefreshStatus == .willEndRefreshing {
                contentInset.top -= oldValue.top
                self.topRefreshStatus = .normal
                self.top?.endRefreshing()
            }
            
            // - bottom
            if self.bottomRefreshStatus == .willBeginRefreshing {
                contentInset.bottom += self.appendContentInset.bottom
                self.bottomRefreshStatus = .refreshing
                self.bottom?.beginRefreshing()
                
            }
            
            if self.bottomRefreshStatus == .willEndRefreshing {
                contentInset.bottom -= oldValue.bottom
                self.bottomRefreshStatus = .normal
                self.bottom?.endRefreshing()
            }
            
            self.scrollView?.contentInset = contentInset
        }) { _ in
            
            if self.topRefreshStatus == .refreshing {
                self.top?.handleCallback?()
            }
            
            if self.bottomRefreshStatus == .refreshing {
                self.bottom?.handleCallback?()
            }
        }
    }
    
    
    /// 更新Offset 判断是否能进入刷新
    fileprivate func updateOffset() {
        
        // 保证只有一个正在刷新
        guard self.topRefreshStatus == .normal && self.bottomRefreshStatus == .normal else {
            return
        }
        
        guard self.preOffsetY != self.offsetMinY else {
            return
        }
        self.preOffsetY = self.offsetMinY
        
        let isDragging = self.scrollView?.isDragging ?? false
        
        // - topProgress
        let topProgress = self.offsetMinY / -self.refreshHeight
        
        // - bottomProgress
        let maximumBottom = self.maximumBottom
        let currentBottom = (self.scrollView?.bounds.height ?? 0) - self.safeArea.bottom + self.offsetMinY
        let bottomProgress = (currentBottom - maximumBottom) / self.refreshHeight
        
        // - update
        if self.top != nil && self.topRefreshStatus < .willBeginRefreshing {
            self.top?.refreshProgress(topProgress)
        }
        
        if self.bottom != nil && self.bottomRefreshStatus < .willBeginRefreshing {
            self.bottom?.refreshProgress(bottomProgress)
        }
        
        print("y", self.offsetMinY, "t", topProgress, "b", bottomProgress)
        guard isDragging else {
            /// 判断是否能进入刷新
            
            if self.recordTopProgress >= 1 && self.topRefreshStatus < .willBeginRefreshing {
                self.recordTopProgress = 0
                self.beginTopRefreshing()
            }
            
            if self.recordBottomProgress >= 1 && self.bottomRefreshStatus < .willBeginRefreshing {
                self.recordBottomProgress = 0
                self.beginBottomRefreshing()
            }
            return
        }
        
        // - reocrd
        if self.topRefreshStatus < .willBeginRefreshing && self.top != nil {
            self.recordTopProgress = topProgress
        }
        
        if self.bottomRefreshStatus < .willBeginRefreshing && self.bottom != nil {
            self.recordBottomProgress = bottomProgress
        }
    }
    
    
    /// - top
    func beginTopRefreshing() {
        guard self.topRefreshStatus < .willBeginRefreshing else {
            return
        }
        self.topRefreshStatus = .willBeginRefreshing
        self.appendContentInset.top = self.refreshHeight
    }
    
    func endTopRefresing() {
        guard self.topRefreshStatus == .refreshing else {
            return
        }
        self.topRefreshStatus = .willEndRefreshing
        self.appendContentInset.top = 0
    }
    
    /// - bottom
    func beginBottomRefreshing() {
        guard self.bottomRefreshStatus < .willBeginRefreshing else {
            return
        }
        self.bottomRefreshStatus = .willBeginRefreshing
        
        let boundsHeight = (self.scrollView?.bounds.height ?? 0) - self.safeArea.bottom - self.safeArea.top
        
        var appendBottom: CGFloat = 0
        if self.maximumBottom <= boundsHeight {
            appendBottom = boundsHeight - self.currentBottom + self.refreshHeight
        } else {
            appendBottom = self.refreshHeight
        }
        self.appendContentInset.bottom = appendBottom
    }
    
    func endBottomRefresing() {
        guard self.bottomRefreshStatus == .refreshing else {
            return
        }
        self.bottomRefreshStatus = .willEndRefreshing
        // 等待其他操作完成在更新 比如 reloadData 之后更新不会出现下滑动情况
        DispatchQueue.main.async {
            self.appendContentInset.bottom = 0
        }
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
