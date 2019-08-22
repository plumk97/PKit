//
//  PLPhotoBrowserPage.swift
//  PLKit
//
//  Created by iOS on 2019/5/16.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass
import YYImage

fileprivate class PLPhotoClosePanGestureRecognizer: UIGestureRecognizer {
    
    private var beginPoint = CGPoint.zero
    private var point = CGPoint.zero
    private weak var firstTouch: UITouch?
    var isRunning = false
    
    
    override func reset() {
        super.reset()
        self.firstTouch = nil
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
        guard self.firstTouch?.phase == .ended else {
            return
        }
        point = self.firstTouch?.location(in: self.view) ?? .zero
        if self.state != .possible {
            self.state = .ended
        }
        
        self.reset()
    }
    
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        guard self.firstTouch?.phase == .cancelled else {
            return
        }
        
        point = self.firstTouch?.location(in: self.view) ?? .zero
        if self.state != .possible {
            self.state = .cancelled
        }
        
        self.reset()
    }
}

class PLPhotoBrowserPage: UIScrollView {
    typealias SingleTapCallback = (PLPhotoBrowserPage) -> Void
    typealias LongPressCallback = (PLPhotoBrowserPage) -> Void
    typealias PanCloseCallback = (PLPhotoBrowserPage, CGFloat) -> Void
    typealias ClosedCallback = (PLPhotoBrowserPage) -> Void
    
    var imageView: YYAnimatedImageView!
    var image: UIImage? {
        didSet {
            self.imageView.image = image
            self.resetZero()
        }
    }
    
    var didSingleTapCallback: SingleTapCallback?
    var longPressCallback: LongPressCallback?
    var panCloseCallback: PanCloseCallback?
    var closedCallback: ClosedCallback?
    
    fileprivate var panGesture: PLPhotoClosePanGestureRecognizer!
    private var panLastPoint: CGPoint = .zero
    private var panBeginPoint: CGPoint = .zero
    
    private var disableLayout = false
    private var preBoundsSize = CGSize.zero
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.imageView = YYAnimatedImageView.init(frame: .zero)
        self.addSubview(self.imageView)
        
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.delegate = self
        
        let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(doubleTapGestureHandle(_ :)))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)

        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(singleTapGestureHandle(_ :)))
        self.addGestureRecognizer(singleTap)
        singleTap.require(toFail: doubleTap)

        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressGestureHandle(_ :)))
        self.addGestureRecognizer(longPress)
        
        
        panGesture = PLPhotoClosePanGestureRecognizer.init(target: self, action: #selector(panGestureHandle(_ :)))
        panGesture.delegate = self
        self.addGestureRecognizer(panGesture)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.disableLayout == false {
            self.update()
        }
    }
    
    func resetZero() {
        
        self.minimumZoomScale = 1
        
        let imageSize = self.imageView.image?.size ?? .zero
        if imageSize.equalTo(.zero) {
            self.maximumZoomScale = 1
        } else {
            let ratio = min(imageSize.width / self.bounds.width, imageSize.height / self.bounds.height)
            self.maximumZoomScale = 1 / ratio + 1
        }
        self.setZoomScale(self.minimumZoomScale, animated: false)
        self.update(isReset: true)
    }
    
    func update(isReset: Bool = false) {
        
        guard let image = self.imageView.image else {
            return
        }
        
        var imageSize = PLPhotoBrowserPage.scale(fromSize: image.size, targetSize: self.bounds.size)
        
        imageSize.width *= self.zoomScale
        imageSize.height *= self.zoomScale
        
        self.imageView.frame.size = imageSize
        
        let width = isReset ? self.bounds.width : max(self.bounds.width, self.contentSize.width)
        let height = isReset ? self.bounds.height : max(self.bounds.height, self.contentSize.height)
        if isReset {
            self.contentSize = .init(width: width, height: height)
        }
        self.imageView.frame.origin = .init(x: (width - imageSize.width) / 2, y: (height - imageSize.height) / 2)
    }
    
    // MARK: - Gesture
    @objc func doubleTapGestureHandle(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if self.zoomScale <= self.minimumZoomScale {
                self.zoom(to: .init(origin: sender.location(in: self), size: .zero), animated: true)
            } else {
                self.setZoomScale(self.minimumZoomScale, animated: true)
            }
        }
    }
    
    @objc func singleTapGestureHandle(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            self.didSingleTapCallback?(self)
        }
    }
    
    @objc func longPressGestureHandle(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            self.longPressCallback?(self)
        }
    }
    
    @objc fileprivate func panGestureHandle(_ sender: PLPhotoClosePanGestureRecognizer) {
        let point = sender.location(in: self)
        var progress: CGFloat = 0
        if sender.state == .began {
            
            self.panBeginPoint = point
            self.disableLayout = true
        } else if sender.state == .changed {
            
            progress = (point.y - self.panBeginPoint.y) / 200
            let scale = min(1, max(0.6, 1 - progress))
            self.imageView.transform = CGAffineTransform.identity.translatedBy(x: (point.x - self.panBeginPoint.x), y: point.y - self.panBeginPoint.y).scaledBy(x: scale, y: scale)
            self.panCloseCallback?(self, progress)
        } else {
            
            progress = (point.y - self.panBeginPoint.y) / 200
            if progress >= 0.2 {
                self.closedCallback?(self)
                self.disableLayout = false
            } else {
                self.panCloseCallback?(self, 0)
                UIView.animate(withDuration: 0.25, animations: {
                    self.imageView.transform = .identity
                }) { (_) in
                    self.disableLayout = false
                }
            }
        }
        
        self.panLastPoint = point
    }
    
    
    // MARK: - Static
    static func scale(fromSize: CGSize, targetSize: CGSize) -> CGSize {
        let ratio = min(1, min(targetSize.width / fromSize.width, targetSize.height / fromSize.height))
        return .init(width: fromSize.width * ratio, height: fromSize.height * ratio)
    }
}

// MARK: - UIScrollViewDelegate
extension PLPhotoBrowserPage: UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.setNeedsLayout()
        self.layoutIfNeeded()
        // 如果已经放大则不可以拖动关闭
        self.panGesture.isEnabled = scrollView.zoomScale <= scrollView.minimumZoomScale
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}


// MARK: - UIGestureRecognizerDelegate
extension PLPhotoBrowserPage: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer == self.panGesture {
            return !self.panGesture.isRunning
        }
        return false
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.panGesture.isRunning {
            return false
        }
        return true
    }
}
