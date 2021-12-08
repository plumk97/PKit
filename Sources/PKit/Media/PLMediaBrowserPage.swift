//
//  PLMediaBrowserPage.swift
//  PLKit
//
//  Created by Plumk on 2020/12/17.
//  Copyright © 2020 Plumk. All rights reserved.
//

import UIKit

open class PLMediaBrowserPage: UIView, UIScrollViewDelegate {
    
    /// 手势关闭进度
    public typealias ClosePrgoressCallback = (PLMediaBrowserPage, CGFloat) -> Void
    
    /// 关闭回调
    public typealias ClosedCallback = (PLMediaBrowserPage, _ isTapClose: Bool) -> Void
    
    /// 手势关闭进度回调
    open var closeProgressCallback: ClosePrgoressCallback?
    
    /// 关闭回调
    open var closedCallback: ClosedCallback?
    
    /// 关闭手势
    open var closeGesture: CloseGestureRecognizer!
    
    /// 单击关闭手势
    open var singleTapGesture: UITapGestureRecognizer!
    
    open private(set) var media: PLMedia!
    
    private var panLastPoint: CGPoint = .zero
    private var panBeginPoint: CGPoint = .zero
    
    open private(set) var scrollView: UIScrollView!
    open private(set) var contentView: UIView!
    
    open private(set) var loadingIndicatorView: UIActivityIndicatorView!
    private var loadingShowCount = 0
    
    /// 封面图片 与消失过渡动画有关 不返回只是渐隐动画
    open var coverImage: UIImage? {
        return nil
    }
    
    public required init(media: PLMedia) {
        super.init(frame: .zero)
        self.media = media
        self.commInit()
        self.loadResource()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commInit()
    }
    
    open func commInit() {
        
        self.scrollView = UIScrollView()
        self.scrollView.delegate = self
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.minimumZoomScale = 1
        self.addSubview(self.scrollView)
        
        self.contentView = UIView()
        self.scrollView.addSubview(self.contentView)
        
        self.loadingIndicatorView = UIActivityIndicatorView(style: .white)
        self.addSubview(self.loadingIndicatorView)

        self.closeGesture = CloseGestureRecognizer.init(target: self, action: #selector(closeGestureHandle(_ :)))
        self.closeGesture.delegate = self
        self.addGestureRecognizer(self.closeGesture)
        
        self.singleTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(singleTapGestureHandle(_ :)))
        self.addGestureRecognizer(self.singleTapGesture)
    }
    
    
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.scrollView.frame = self.bounds
        self.loadingIndicatorView.sizeToFit()
        
        if #available(iOS 11.0, *) {
            self.loadingIndicatorView.frame.origin = .init(x: self.layoutMargins.left,
                                                           y: self.layoutMargins.top)
        }
    }
    
    /// 加载资源 子类重写实现
    open func loadResource() {
        
    }
    
    // MARK: - Loading Indicator
    open func showLoadingIndicator() {
        self.loadingShowCount += 1
        guard !self.loadingIndicatorView.isAnimating else {
            return
        }
        self.loadingIndicatorView.startAnimating()
    }
    
    open func hideLoadingIndicator() {
        self.loadingShowCount = max(0, self.loadingShowCount - 1)
        guard self.loadingIndicatorView.isAnimating && self.loadingShowCount <= 0 else {
            return
        }
        self.loadingIndicatorView.stopAnimating()
    }
    
    // MARK: - Gesture
    @objc open func singleTapGestureHandle(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            self.closedCallback?(self, true)
        }
    }
    
    @objc fileprivate func closeGestureHandle(_ sender: CloseGestureRecognizer) {
        let point = sender.location(in: self)
        var progress: CGFloat = 0
        if sender.state == .began {

            self.panBeginPoint = point
        } else if sender.state == .changed {

            progress = (point.y - self.panBeginPoint.y) / 200
            let scale = min(1, max(0.6, 1 - progress))
            self.contentView.transform = CGAffineTransform.identity.translatedBy(x: (point.x - self.panBeginPoint.x), y: point.y - self.panBeginPoint.y).scaledBy(x: scale, y: scale)
            self.closeProgressCallback?(self, progress)
        } else {

            progress = (point.y - self.panBeginPoint.y) / 200
            if progress >= 0.2 {
                self.closedCallback?(self, false)
            } else {
                self.closeProgressCallback?(self, 0)
                UIView.animate(withDuration: 0.25, animations: {
                    self.contentView.transform = .identity
                })
            }
        }
        self.panLastPoint = point
    }
    
    // MARK: - Static method
    /// 缩放Size到目标Size
    /// - Parameters:
    ///   - size:
    ///   - targetSize:
    /// - Returns:
    public static func fitSize(_ size: CGSize, targetSize: CGSize) -> CGSize {
        let ratio = min(targetSize.width / size.width, targetSize.height / size.height)
        let newSize = CGSize.init(width: Int(size.width * ratio), height: Int(size.height * ratio))
        return newSize
    }
}


// MARK: - UIGestureRecognizerDelegate
extension PLMediaBrowserPage: UIGestureRecognizerDelegate {
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer == self.closeGesture {
            return !self.closeGesture.isRunning
        }
        return false
    }
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer != self.closeGesture && self.closeGesture.isRunning {
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

// MARK: - Class CloseGestureRecognizer
extension PLMediaBrowserPage {
    open class CloseGestureRecognizer: UIGestureRecognizer {
        private var beginPoint = CGPoint.zero
        private var point = CGPoint.zero
        private weak var firstTouch: UITouch?
        open  var isRunning = false
        
        
        open override func reset() {
            super.reset()
            
            self.firstTouch = nil
            self.isRunning = false
        }
        
        open override func location(in view: UIView?) -> CGPoint {
            return self.point
        }
        
        open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
            guard self.firstTouch == nil else {
                return
            }
            self.firstTouch = touches.first
            self.isRunning = false
            beginPoint = self.firstTouch?.location(in: self.view) ?? .zero
            point = beginPoint
        }
        
        open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
            guard self.firstTouch?.phase == .moved else {
                return
            }
            
            point = self.firstTouch?.location(in: self.view) ?? .zero
            if point.y - beginPoint.y > 20 ||  point.y - beginPoint.y < -20 {
                if self.state != .began {
                    self.state = .began
                    self.isRunning = true
                } else {
                    self.state = .changed
                }
            }
        }
        
        open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
            defer {
                self.reset()
            }
            
            guard self.firstTouch?.phase == .ended else {
                return
            }
            point = self.firstTouch?.location(in: self.view) ?? .zero
            if self.state != .possible {
                self.state = .ended
            } else {
                touches.forEach({
                    self.ignore($0, for: event)
                })
            }
        }
        
        
        open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
            defer {
                self.reset()
            }
            
            guard self.firstTouch?.phase == .cancelled else {
                return
            }
            
            point = self.firstTouch?.location(in: self.view) ?? .zero
            if self.state != .possible {
                self.state = .cancelled
            } else {
                touches.forEach({
                    self.ignore($0, for: event)
                })
            }
        }
    }
}
