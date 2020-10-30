//
//  PLPageScrollView.swift
//  PLKit
//
//  Created by Plumk on 2019/4/30.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit
@objc protocol PLPageScrollViewDelegate: NSObjectProtocol {
    
    /// PageScrollView 本身滚动
    ///
    /// - Parameter scrollView:
    @objc optional func pageScrollViewDidScroll(_ scrollView: PLPageScrollView)
    
    /// 分页ScrollView 滚动
    ///
    /// - Parameter scrollView:
    @objc optional func pageScrollViewContentPageDidScroll(_ scrollView: PLPageScrollView)
    
    /// 分页ScrollView 开始拖动
    ///
    /// - Parameter scrollView:
    @objc optional func pageScrollViewContentPageWillBeginDragging(_ scrollView: PLPageScrollView)
    
    /// 分页ScrollView 将要停止拖动
    ///
    /// - Parameters:
    ///   - scrollView:
    ///   - velocity:
    ///   - targetContentOffset:
    @objc optional func pageScrollViewContentPageWillEndDragging(_ scrollView: PLPageScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    
    /// 切换分页
    ///
    /// - Parameters:
    ///   - scrollView:
    ///   - index:
    @objc optional func pageScrollView(_ scrollView: PLPageScrollView, didChangeCurrentIndex index: Int)
}

class PLPageScrollView: UIScrollView {
    
    var pldelegate: PLPageScrollViewDelegate?
    var headerView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let unheaderView = headerView {
                self.addSubview(unheaderView)
            }
            self.relayoutContentViews()
        }
    }
    
    var contentScrollViews: [UIScrollView]? {
        didSet {
            oldValue?.forEach({
                $0.removeFromSuperview()
            })
            
            contentScrollViews?.forEach({
                $0.pl_pageScrollView = self
                
                $0.panGestureRecognizer.require(toFail: self.panGestureRecognizer)
                self.pageScrollView.addSubview($0)
            })
            
            self.relayoutContentViews()
        }
    }
    
    /// 当前显示Index
    private(set) var currentScrollViewIndex: Int = 0
    
    /// 当前显示ScrollView
    var currentScrollView: UIScrollView? {
        return self.contentScrollViews?[self.currentScrollViewIndex]
    }
    
    /// 分页ScrollView
    private(set) var pageScrollView: UIScrollView!
    
    /// headerViewBottom
    fileprivate var headerViewBottom: CGFloat {
        return self.headerView?.frame.maxY ?? 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.alwaysBounceVertical = true
        self.delegate = self
        
        self.pageScrollView = UIScrollView()
        self.pageScrollView.delegate = self
        self.pageScrollView.isPagingEnabled = true
        self.pageScrollView.bounces = false
        self.addSubview(self.pageScrollView)
        
        if #available(iOS 11.0, *) {
            self.contentInsetAdjustmentBehavior = .never
        }
        
        UIScrollView.exchange()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// 重新布局
    fileprivate func relayoutContentViews() {
        if let headerView = self.headerView {
            headerView.frame.origin = .init(x: (self.bounds.width - headerView.bounds.width) / 2, y: 0)
        }
        
        self.pageScrollView.frame = .init(x: 0, y: self.headerViewBottom, width: self.bounds.width, height: self.bounds.height)
        self.pageScrollView.contentSize = .init(width: self.bounds.width * CGFloat(self.contentScrollViews?.count ?? 0), height: 0)
        
        let rect = CGRect.init(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        self.contentScrollViews?.enumerated().forEach({ (offset, element) in
            element.frame = rect.offsetBy(dx: CGFloat(offset) * self.bounds.width, dy: 0)
        })
    }
    
    
    /// 根据当前显示的ScrollView 设置ContentSize
    fileprivate func updateContentSize() {
        guard let scrollView = self.currentScrollView else {
            return
        }
        
        var contentSize = scrollView.contentSize
        contentSize.height = max(self.frame.height, contentSize.height)
        contentSize.height += self.headerViewBottom
        if !self.contentSize.equalTo(contentSize) {
            self.contentSize = contentSize
        }
        
        var contentInset = scrollView.contentInset
        if contentInset.bottom > 0 {
            let bottom = scrollView.contentInset.bottom + scrollView.contentSize.height
            // 等于44 判断为上拉加载
            if bottom - self.bounds.height == 44 {
                contentInset.bottom = 44
            }
        }
        if !self.contentInset.equalTo(contentInset) {
            self.contentInset = contentInset
        }
    }
    
    /// 更新下标
    fileprivate func updateCurrentPageIndex() {
        let index = Int(self.pageScrollView.contentOffset.x / self.pageScrollView.frame.width)
        
        if self.currentScrollViewIndex != index {
            self.currentScrollViewIndex = index
            self.pldelegate?.pageScrollView?(self, didChangeCurrentIndex: index)
        }
    }
    
    /// 更新offset
    fileprivate func updateContentOffset() {
        
        guard let scrollView = self.currentScrollView else {
            return
        }
        
        if self.contentOffset.y >= self.headerViewBottom {
            let offset = scrollView.contentOffset
            self.setContentOffset(.init(x: 0, y: offset.y + self.headerViewBottom), animated: false)
        }
    }
    
    /// 设置当前显示页
    ///
    /// - Parameters:
    ///   - index:
    ///   - animated:
    func setCurrentPageIndex(_ index: Int, animated: Bool) {
        self.pageScrollView.setContentOffset(.init(x: CGFloat(index) * self.pageScrollView.frame.width, y: 0), animated: animated)
    }
}

extension PLPageScrollView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == self else {
            self.pldelegate?.pageScrollViewContentPageDidScroll?(self)
            return
        }
        self.updateContentSize()
        var offset = scrollView.contentOffset
        
        /// 去掉 headerViewBottom
        offset.y = max(0, offset.y - self.headerViewBottom)
        
        if scrollView.contentOffset.y < self.headerViewBottom {
            // 当mainScrollView offset.y 小于最小高度时 设置全部 content scrollview
            self.contentScrollViews?.forEach({ $0.contentOffset = offset })
        } else {
            self.currentScrollView?.contentOffset = offset
        }
        
        self.pageScrollView.frame.origin = .init(x: 0, y: max(self.headerViewBottom, offset.y + self.headerViewBottom))
        self.pldelegate?.pageScrollViewDidScroll?(self)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard self.pageScrollView == scrollView else {
            return
        }
        self.updateCurrentPageIndex()
        self.updateContentOffset()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard self.pageScrollView == scrollView else {
            return
        }
        
        self.updateCurrentPageIndex()
        self.updateContentOffset()
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView == self.pageScrollView else {
            return
        }
        self.pldelegate?.pageScrollViewContentPageWillBeginDragging?(self)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard scrollView == self.pageScrollView else {
            return
        }
        self.pldelegate?.pageScrollViewContentPageWillEndDragging?(self, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
}

fileprivate var kPLPageScrollView = "kPLPageScrollView"
fileprivate var isExchanged = false
extension UIScrollView {
    
    static func exchange() {
        if isExchanged == false {
            let m1 = class_getInstanceMethod(self, #selector(getter: UIScrollView.isDragging))
            let m2 = class_getInstanceMethod(self, Selector.init(("_isDragging")))
            method_exchangeImplementations(m1!, m2!)
            isExchanged = true
        }
    }
    
    @objc var _isDragging: Bool {
        if self is PLPageScrollView {
            return self._isDragging
        }
        return self.pl_pageScrollView?.isDragging ?? self._isDragging
    }
    
    var pl_pageScrollView: PLPageScrollView? {
        set {
            objc_setAssociatedObject(self, &kPLPageScrollView, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        
        get {
            return objc_getAssociatedObject(self, &kPLPageScrollView) as? PLPageScrollView
        }
    }
}
