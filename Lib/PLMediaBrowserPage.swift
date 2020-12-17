//
//  PLMediaBrowserPage.swift
//  PLKit
//
//  Created by mini2019 on 2020/12/17.
//  Copyright © 2020 Plumk. All rights reserved.
//

import UIKit

class PLMediaBrowserPage: UIView, UIScrollViewDelegate {
    
    /// 手势关闭进度
    typealias ClosePrgoressCallback = (PLMediaBrowserPage, CGFloat) -> Void
    
    /// 关闭回调
    typealias ClosedCallback = (PLMediaBrowserPage, _ isTapClose: Bool) -> Void
    
    
    var media: PLMedia? {
        didSet {
            self.reloadData()
        }
    }
    
    /// 手势关闭进度回调
    var closeProgressCallback: ClosePrgoressCallback?
    
    /// 关闭回调
    var closedCallback: ClosedCallback?
    
    /// 关闭手势
    var closeGesture: CloseGestureRecognizer!
    
    /// 单击关闭手势
    var singleTapGesture: UITapGestureRecognizer!
    
    private var panLastPoint: CGPoint = .zero
    private var panBeginPoint: CGPoint = .zero
    
    private(set) var scrollView: UIScrollView!
    private(set) var contentView: UIView!
    
    private(set) var loadingIndicatorView: UIActivityIndicatorView!
    private var loadingShowCount = 0
    
    /// 封面图片 与消失过渡动画有关 不返回只是渐隐动画
    var coverImage: UIImage? {
        return nil
    }
    
    required init(media: PLMedia) {
        super.init(frame: .zero)
        self.media = media
        self.commInit()
        self.reloadData()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commInit()
    }
    
    func commInit() {
        
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
    
    func reloadData() {
        
    }
    
    @objc func singleTapGestureHandle(_ sender: UITapGestureRecognizer) {
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
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.scrollView.frame = self.bounds
        self.loadingIndicatorView.sizeToFit()
        
        if #available(iOS 11.0, *) {
            
            self.loadingIndicatorView.frame.origin = .init(x: self.layoutMargins.left,
                                                           y: self.layoutMargins.top)
        }
    }
    
    func _showLoading() {
        self.loadingShowCount += 1
        guard !self.loadingIndicatorView.isAnimating else {
            return
        }
        self.loadingIndicatorView.startAnimating()
    }
    
    func _hideLoading() {
        self.loadingShowCount = max(0, self.loadingShowCount - 1)
        guard self.loadingIndicatorView.isAnimating && self.loadingShowCount <= 0 else {
            return
        }
        self.loadingIndicatorView.stopAnimating()
    }
    
    
    static func fitSize(_ size: CGSize, targetSize: CGSize) -> CGSize {
        let ratio = min(targetSize.width / size.width, targetSize.height / size.height)
        let newSize = CGSize.init(width: size.width * ratio, height: size.height * ratio)
        return newSize
    }
}


// MARK: - UIGestureRecognizerDelegate
extension PLMediaBrowserPage: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer == self.closeGesture {
            return !self.closeGesture.isRunning
        }
        return false
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer != self.closeGesture && self.closeGesture.isRunning {
            return false
        }
        return true
    }
}

// MARK: - Class CloseGestureRecognizer
extension PLMediaBrowserPage {
    class CloseGestureRecognizer: UIGestureRecognizer {
        private var beginPoint = CGPoint.zero
        private var point = CGPoint.zero
        private weak var firstTouch: UITouch?
        var isRunning = false
        
        
        override func reset() {
            super.reset()
            self.firstTouch = nil
            self.isRunning = false
        }
        
        override func location(in view: UIView?) -> CGPoint {
            return self.point
        }
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
            guard self.firstTouch == nil else {
                return
            }
            self.firstTouch = touches.first
            self.isRunning = false
            beginPoint = self.firstTouch?.location(in: self.view) ?? .zero
            point = beginPoint
        }
        
        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
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
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
            defer {
                self.reset()
            }
            
            guard self.firstTouch?.phase == .ended else {
                return
            }
            point = self.firstTouch?.location(in: self.view) ?? .zero
            if self.state != .possible {
                self.state = .ended
            }
        }
        
        
        override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
            defer {
                self.reset()
            }
            
            guard self.firstTouch?.phase == .cancelled else {
                return
            }
            
            point = self.firstTouch?.location(in: self.view) ?? .zero
            if self.state != .possible {
                self.state = .cancelled
            }
        }
    }
}
