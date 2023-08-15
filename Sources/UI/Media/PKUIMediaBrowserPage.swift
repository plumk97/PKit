//
//  PKUIMediaBrowserPage.swift
//  PKit
//
//  Created by Plumk on 2020/12/17.
//  Copyright © 2020 Plumk. All rights reserved.
//

import UIKit

open class PKUIMediaBrowserPage: UIView, UIGestureRecognizerDelegate {
    
    weak var delegate: PKUIMediaBrowserPageDelete?
    
    public let media: PKUIMedia
    
    /// 滑动关闭手势
    public let panCloseGesture = PKUIPanCloseGestureRecognizer()
    
    /// 单击关闭手势
    public let tapCloseGesture = UITapGestureRecognizer()
    
    /// 关闭手势开始位置
    var closePanBeginPoint: CGPoint = .zero
    
    /// 关闭手势当前位置
    var closePanPoint: CGPoint = .zero
    
    public required init(media: PKUIMedia) {
        self.media = media
        super.init(frame: .zero)
        
        self.commInit()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func commInit() {
        
        
        self.panCloseGesture.delegate = self
        self.panCloseGesture.addTarget(self, action: #selector(panCloseGestureHandle))
        self.addGestureRecognizer(self.panCloseGesture)
        
        self.tapCloseGesture.addTarget(self, action: #selector(tapCloseGestureHandle))
        self.addGestureRecognizer(self.tapCloseGesture)   
    }
    
    @objc open func panCloseGestureHandle(_ sender: PKUIPanCloseGestureRecognizer) {
        let point = sender.location(in: self)
        defer {
            self.closePanPoint = point
        }
        
        if sender.state == .began {

            self.closePanBeginPoint = point
            self.delegate?.pagePanCloseStart(self)
            
        } else if sender.state == .changed {

            let progress = (point.y - self.closePanBeginPoint.y) / 200
            self.delegate?.pagePanCloseProgressUpdate(self, progress: progress)
            self.closePanProgressUpdate(progress: progress, beginPoint: self.closePanBeginPoint, offset: point)
            
        } else {

            let progress = (point.y - self.closePanBeginPoint.y) / 200
            if progress >= 0.2 {
                
                if let formView = self.delegate?.browserFromView() {
                    self.delegate?.pagePanCloseProgressUpdate(self, progress: 1)
                    self.closePanEnd(isClosed: true, fromView: self.delegate?.browserFromView()) {
                        self.delegate?.pagePanCloseEnd(self, isClosed: true)
                    }
                } else {
                    self.delegate?.pageDidClosed(self)
                }
                
            } else {
                self.delegate?.pagePanCloseProgressUpdate(self, progress: 0)
                self.closePanEnd(isClosed: false, fromView: nil) {
                    
                }
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
    
    /// 滑动关闭完成
    /// - Parameters:
    ///   - isClosed: 是否关闭
    ///   - fromView:
    open func closePanEnd(isClosed: Bool, fromView: UIView?, complete: @escaping () -> Void) {
        complete()
    }
    
    // MARK: - Internal
    
    
    // MARK: - UIGestureRecognizerDelegate
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer == self.panCloseGesture {
            return !self.panCloseGesture.isRunning
        }
        return false
    }
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer != self.panCloseGesture && self.panCloseGesture.isRunning {
            return false
        }
        return true
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive event: UIEvent) -> Bool {
        guard let view = event.allTouches?.first?.view else {
            return true
        }
        
        return !view.isKind(of: UIControl.self)
    }
}


// MARK: - PKUIMediaBrowserPageDelete
@objc public protocol PKUIMediaBrowserPageDelete: NSObjectProtocol {
    
    /// 关闭
    /// - Parameter page:
    func pageDidClosed(_ page: PKUIMediaBrowserPage)
    
    /// 滑动关闭手势开始
    /// - Parameter page:
    func pagePanCloseStart(_ page: PKUIMediaBrowserPage)
    
    /// 滑动关闭进度更新
    /// - Parameters:
    ///   - page:
    ///   - progress:
    func pagePanCloseProgressUpdate(_ page: PKUIMediaBrowserPage, progress: CGFloat)
    
    /// 滑动关闭手势结束
    /// - Parameters:
    ///   - page:
    ///   - isClosed:
    func pagePanCloseEnd(_ page: PKUIMediaBrowserPage, isClosed: Bool)
    
    ///
    /// - Returns: 
    func browserFromView() -> UIView?
}
