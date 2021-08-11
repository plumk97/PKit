//
//  PLPageScrollView.swift
//  PLKit
//
//  Created by Plumk on 2019/4/30.
//  Copyright © 2019 Plumk. All rights reserved.
//

import UIKit

class PLPageScrollView: UIScrollView {
    
    weak var pldelegate: UIScrollViewDelegate?
    
    private(set) var headerView: UIView?
    private(set) var scrollViews = [UIScrollView]()
    
    /// 当前显示Index
    private(set) var pageIndex: Int = 0
    
    /// 分页ScrollView
    private(set) var pageScrollView: UIScrollView!
    
    var currentScrollView: UIScrollView? {
        return self.pageIndex >= 0 && self.pageIndex < self.scrollViews.count ? self.scrollViews[self.pageIndex] : nil
    }
    
    fileprivate var headerHeight: CGFloat {
        return self.headerView?.frame.maxY ?? 0
    }
    
    fileprivate var prevBoundsSize: CGSize = .zero
    fileprivate var prevContentOffset: CGPoint = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.alwaysBounceVertical = true
        self.showsVerticalScrollIndicator = false
        
        self.pageScrollView = UIScrollView()
        self.pageScrollView.delegate = self
        self.pageScrollView.isPagingEnabled = true
        self.pageScrollView.bounces = false
        self.pageScrollView.showsHorizontalScrollIndicator = false
        self.addSubview(self.pageScrollView)
        
        if #available(iOS 11.0, *) {
            self.pageScrollView.contentInsetAdjustmentBehavior = .never
            self.contentInsetAdjustmentBehavior = .never
        }
        
        UIScrollView.exchange()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setHeaderView(_ headerView: UIView) {
        self.headerView?.removeFromSuperview()
        self.headerView = headerView
        self.addSubview(headerView)
        
        self.setNeedsLayout()
    }
    
    func setScrollViews(_ scrollViews: [UIScrollView]) {
        self.scrollViews.forEach({
            $0.removeFromSuperview()
        })
        
        self.scrollViews = scrollViews
        
        scrollViews.forEach({
            $0.panGestureRecognizer.require(toFail: self.panGestureRecognizer)
            self.pageScrollView.addSubview($0)
        })
        self.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !self.prevBoundsSize.equalTo(self.bounds.size) {
            self.prevBoundsSize = self.bounds.size
            
            if let headerView = self.headerView {
                headerView.frame.origin = .init(x: (self.bounds.width - headerView.bounds.width) / 2, y: 0)
            }

            self.pageScrollView.frame = .init(x: 0, y: max(self.headerHeight, self.contentOffset.y), width: self.bounds.width, height: self.bounds.height)
            self.pageScrollView.contentSize = .init(width: CGFloat(self.scrollViews.count) * self.bounds.width, height: 0)

            if self.scrollViews.count > 0 {
                for (i, scrollView) in self.scrollViews.enumerated() {
                    scrollView.frame = CGRect.init(x: CGFloat(i) * self.bounds.width, y: 0, width: self.pageScrollView.bounds.width, height: self.pageScrollView.bounds.height)
                }
            }
        }
        
        
        self.updateContentSize()
        self.updateChildOffset()
    }

    /// 更新下标
    fileprivate func updateCurrentPageIndex() {
        let pageIndex = Int(round(self.pageScrollView.contentOffset.x / self.pageScrollView.frame.width))

        if self.pageIndex != pageIndex {
            self.pageIndex = pageIndex
            
            self.updateContentSize()
            if let scrollView = self.currentScrollView {
                if self.contentOffset.y >= self.headerHeight {
                    self.contentOffset = .init(x: 0, y: scrollView.contentOffset.y + self.headerHeight)
                }
            }
            
            
        }
    }
    
    /// 根据当前显示的ScrollView 设置ContentSize
    fileprivate func updateContentSize() {
        guard let scrollView = self.currentScrollView else {
            return
        }
        
        if true {
            // - 设置contentSize
            let contentInset = scrollView.contentInset
            let contentSize = scrollView.contentSize
            
            let contentHeight = max(self.bounds.height + self.headerHeight,
                                    contentSize.height + contentInset.bottom + self.headerHeight)
            if contentHeight != self.contentSize.height {
                self.contentSize = .init(width: 0, height: contentHeight)
            }
        }
    }
    
    /// 根据当前的Offset设置child 的 offset
    fileprivate func updateChildOffset() {
        guard let scrollView = self.currentScrollView else {
            return
        }
        
        if !self.prevContentOffset.equalTo(self.contentOffset) {
            // 计算偏移
            let offset = self.contentOffset
            self.prevContentOffset = offset
            
            if offset.y >= self.headerHeight {
                self.pageScrollView.frame.origin = .init(x: 0, y: offset.y)
                scrollView.setContentOffset(.init(x: 0, y: offset.y - self.headerHeight), animated: false)
            } else {
                for scrollView in self.scrollViews {
                    if scrollView.contentOffset.y > 0 {
                        scrollView.setContentOffset(.init(x: 0, y: 0), animated: false)
                    }
                }
                
                if self.pageScrollView.frame.minY > self.headerHeight {
                    self.pageScrollView.frame.origin = .init(x: 0, y: self.headerHeight)
                }
            }
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

// MARK: - UIScrollViewDelegate
extension PLPageScrollView: UIScrollViewDelegate {
    
    @available(iOS 2.0, *)
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pldelegate?.scrollViewDidScroll?(scrollView)
    }
    
    @available(iOS 2.0, *)
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.pldelegate?.scrollViewWillBeginDragging?(scrollView)
    }

    @available(iOS 5.0, *)
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.pldelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }

    @available(iOS 2.0, *)
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.pldelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }

    
    @available(iOS 2.0, *)
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        self.pldelegate?.scrollViewWillBeginDecelerating?(scrollView)
    }

    @available(iOS 2.0, *)
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        switch scrollView {
        case self.pageScrollView:
            self.updateCurrentPageIndex()
            
        default:
            break
        }
        
        self.pldelegate?.scrollViewDidEndDecelerating?(scrollView)
    }

    
    @available(iOS 2.0, *)
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        switch scrollView {
        case self.pageScrollView:
            self.updateCurrentPageIndex()
            
        default:
            break
        }
        
        self.pldelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }
}

// MARK: - Exchange isDragging
fileprivate var kPLPageScrollView = "kPLPageScrollView"
fileprivate var isExchanged = false
extension UIScrollView {
    
    static func exchange() {
        if isExchanged == false {
            let m1 = class_getInstanceMethod(self, #selector(getter: UIScrollView.isDragging))
            let m2 = class_getInstanceMethod(self, #selector(getter: self.PLPageScrollView_isDragging))
            method_exchangeImplementations(m1!, m2!)
            isExchanged = true
        }
    }
    
    @objc fileprivate var PLPageScrollView_isDragging: Bool {
        if self is PLPageScrollView {
            return self.PLPageScrollView_isDragging
        }
        return self.pl_pageScrollView?.isDragging ?? self.PLPageScrollView_isDragging
    }
    
    var pl_pageScrollView: PLPageScrollView? {
        return self.superview?.superview as? PLPageScrollView
    }
}
