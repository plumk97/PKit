//
//  PLPageScrollView.swift
//  PLKit
//
//  Created by iOS on 2019/4/30.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class PLPageScrollView: UIScrollView {
    
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
                $0.isScrollEnabled = false
                $0.contentInset = self.contentInset
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
    fileprivate var pageScrollView: UIScrollView!
    
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
        self.addSubview(self.pageScrollView)
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
        contentSize.height += scrollView.contentInset.top + scrollView.contentInset.bottom
        contentSize.height += self.headerViewBottom
        if !self.contentSize.equalTo(contentSize) {
            self.contentSize = contentSize
        }
    }
    
    /// 更新下标
    fileprivate func updateCurrentPageIndex() {
        let index = Int(self.pageScrollView.contentOffset.x / self.pageScrollView.frame.width)
        
        if self.currentScrollViewIndex != index {
            self.currentScrollViewIndex = index
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
}

extension PLPageScrollView: UIScrollViewDelegate {
    
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        guard scrollView == self else {
//            return
//        }
//        self.updateContentSize()
//    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == self else {
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
}
