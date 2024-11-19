//
//  PKUIMediaBrowserPage.swift
//  PKit
//
//  Created by Plumk on 2023/12/11.
//

import UIKit

public protocol PKUIMediaBrowserPageDelegate: AnyObject {
    
    /// 关闭
    /// - Parameter page:
    func pageDidClosed(_ page: PKUIMediaBrowserPage)
    
    /// 滑动关闭进度更新
    /// - Parameters:
    ///   - page:
    ///   - progress:
    func pagePanCloseProgressUpdate(_ page: PKUIMediaBrowserPage, progress: CGFloat)
}

open class PKUIMediaBrowserPage: UIView {
    
    public required override init(frame: CGRect) {
        super.init(frame: frame)
        self.commInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commInit()
    }
    
    /// dismiss 过渡view
    open var transitioningView: UIView? {
        return nil
    }
    
    public private(set) var media: PKUIMedia?
    
    /// 滑动关闭手势
    public let panCloseGesture = PKUIVerticalPanGestureRecognizer()
    
    /// 单击关闭手势
    public let tapCloseGesture = UITapGestureRecognizer()
    
    /// 关闭手势开始位置
    var closePanBeginPoint: CGPoint = .zero
    
    /// 关闭手势当前位置
    var closePanPoint: CGPoint = .zero
    
    /// 代理
    public weak var delegate: PKUIMediaBrowserPageDelegate?
    
    open func commInit() {
        self.panCloseGesture.addTarget(self, action: #selector(panCloseGestureHandle))
        self.addGestureRecognizer(self.panCloseGesture)
        
        self.tapCloseGesture.addTarget(self, action: #selector(tapCloseGestureHandle))
        self.addGestureRecognizer(self.tapCloseGesture)
    }
    
    open func setMedia(_ media: PKUIMedia) {
        self.media = media
    }
    
    @objc open func panCloseGestureHandle(_ sender: UIPanGestureRecognizer) {
        let point = sender.location(in: self)
        defer {
            self.closePanPoint = point
        }
        
        if sender.state == .began {

            self.closePanBeginPoint = point
        } else if sender.state == .changed {

            let progress = (point.y - self.closePanBeginPoint.y) / 200
            self.delegate?.pagePanCloseProgressUpdate(self, progress: progress)
            self.closePanProgressUpdate(progress: progress, beginPoint: self.closePanBeginPoint, offset: point)
        } else {

            let progress = (point.y - self.closePanBeginPoint.y) / 200
            if progress >= 0.2 {
                self.delegate?.pageDidClosed(self)

            } else {
                self.delegate?.pagePanCloseProgressUpdate(self, progress: 0)
                self.closePanRestore()
            }
        }
    }
    
    @objc open func tapCloseGestureHandle(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            self.delegate?.pageDidClosed(self)
        }
    }
    
    
    /// 滑动关闭手势进度更新
    /// - Parameters:
    ///   - progress:
    ///   - beginPoint:
    ///   - offset:
    open func closePanProgressUpdate(progress: CGFloat, beginPoint: CGPoint, offset: CGPoint) {
        
    }
    
    /// 滑动关闭恢复
    open func closePanRestore() {
        
    }
    
    open func didEnter() {
        
    }
    
    open func didLeave() {
        
    }
}
