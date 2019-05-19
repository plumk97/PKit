//
//  PLPhotoBrowserPage.swift
//  PLKit
//
//  Created by iOS on 2019/5/16.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

fileprivate class PLPhotoClosePanGestureRecognizer: UIGestureRecognizer {
    
    private var beginPoint = CGPoint.zero
    var isRunning = false
    override func shouldRequireFailure(of otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .began
        self.isRunning = false
        beginPoint = touches.first?.location(in: self.view) ?? .zero
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {

        let point = touches.first?.location(in: self.view) ?? .zero
        
        if point.y - beginPoint.y > 10 {
            self.state = .changed
            self.isRunning = true
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .ended
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .cancelled
    }
}

class PLPhotoBrowserPage: UIScrollView {
    typealias SingleTapCallback = (PLPhotoBrowserPage) -> Void
    typealias LongPressCallback = (PLPhotoBrowserPage) -> Void
    typealias PanCloseCallback = (PLPhotoBrowserPage, CGFloat) -> Void
    typealias ClosedCallback = (PLPhotoBrowserPage) -> Void
    
    var imageView: UIImageView!
    var image: UIImage? {
        didSet {
            self.imageView.image = image
            self.reset()
        }
    }
    
    var didSingleTapCallback: SingleTapCallback?
    var longPressCallback: LongPressCallback?
    var panCloseCallback: PanCloseCallback?
    var closedCallback: ClosedCallback?
    
    fileprivate var panGesture: PLPhotoClosePanGestureRecognizer!
    private var panLastPoint: CGPoint = .zero
    private var panBeginY: CGFloat = 0
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.imageView = UIImageView.init(frame: .zero)
        self.addSubview(self.imageView)
        
        self.delegate = self
        self.minimumZoomScale = 1
        self.maximumZoomScale = 3
        
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
        self.update()
    }
    
    func reset() {
        self.zoomScale = self.minimumZoomScale
        self.update()
    }
    
    func update() {
        
        guard let image = self.imageView.image else {
            return
        }
        
        var imageSize = image.size
        
        let ratio = min(1, min(self.bounds.width / imageSize.width, self.bounds.height / imageSize.height))
        
        imageSize.width *= ratio
        imageSize.height *= ratio
        
        imageSize.width *= self.zoomScale
        imageSize.height *= self.zoomScale
        
        self.imageView.frame.size = imageSize
        
        let width = max(self.bounds.width, self.contentSize.width)
        let height = max(self.bounds.height, self.contentSize.height)
     
        self.imageView.frame.origin = .init(x: (width - imageSize.width) / 2, y: (height - imageSize.height) / 2)
    }
    
    
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
            self.panBeginY = self.imageView.frame.maxY
        } else if sender.state == .changed {
            
            let appendX = point.x - self.panLastPoint.x
            let appendY = point.y - self.panLastPoint.y
            
            var center = self.imageView.center
            center.x += appendX
            center.y += appendY
            self.imageView.center = center
            progress = (self.imageView.frame.maxY - self.panBeginY) / (self.bounds.height - self.panBeginY)
            self.panCloseCallback?(self, progress)
        } else {
            progress = (self.imageView.frame.maxY - self.panBeginY) / (self.bounds.height - self.panBeginY)
            if progress >= 0.8 {
                self.closedCallback?(self)
            } else {
                self.panCloseCallback?(self, 0)
                UIView.animate(withDuration: 0.25) {
                    self.imageView.center = .init(x: self.bounds.width / 2, y: self.bounds.height / 2)
                }
            }
            
        }
        self.panLastPoint = point
    }
}

extension PLPhotoBrowserPage: UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}


extension PLPhotoBrowserPage: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        if gestureRecognizer == self.panGesture {

            if otherGestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer != self.panGestureRecognizer {
                if self.panGesture.isRunning {
                    return false
                }
                
                if otherGestureRecognizer.state == .began {
                    self.panGesture.reset()
                    self.panGesture.state = .failed
                }
                
                return true
            }
        }
        return false
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.panGesture {
            
            if self.image == nil {
                return false
            }
            return floor(self.contentSize.height) <= self.bounds.height && floor(self.contentSize.width) <= self.bounds.width
        }
        return true
    }
}
