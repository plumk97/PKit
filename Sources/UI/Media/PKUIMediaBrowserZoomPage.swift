//
//  PKUIMediaBrowserZoomPage.swift
//  PKit
//
//  Created by Plumk on 2023/8/15.
//

import UIKit

open class PKUIMediaBrowserZoomPage: PKUIMediaBrowserPage, UIScrollViewDelegate {

    public let scrollView = UIScrollView()
    
    /// 双击放大放小
    public let doubleTapGesture = UITapGestureRecognizer()
    
    open var zoomViewInitialSize: CGSize {
        return .zero
    }
    
    open override func commInit() {
        super.commInit()
        
        self.scrollView.delegate = self
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.minimumZoomScale = 1
        self.scrollView.maximumZoomScale = 5
        self.addSubview(self.scrollView)
        
        self.doubleTapGesture.addTarget(self, action: #selector(doubleTapGestureHandle))
        self.doubleTapGesture.numberOfTapsRequired = 2
        self.addGestureRecognizer(self.doubleTapGesture)
        
        self.tapCloseGesture.require(toFail: self.doubleTapGesture)
    }
    
    open override func tapCloseGestureHandle(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: false)
        }
        
        super.tapCloseGestureHandle(sender)
    }

    
    @objc open func doubleTapGestureHandle(_ sender: UITapGestureRecognizer) {
        guard self.isCanZoom() else {
            return
        }
        
        if sender.state == .ended, let zoomView = self.viewForZooming(in: self.scrollView) {
            guard self.scrollView.maximumZoomScale > self.scrollView.minimumZoomScale else {
                return
            }
            
            if self.scrollView.zoomScale <= self.scrollView.minimumZoomScale {
                self.scrollView.zoom(to: .init(origin: sender.location(in: zoomView), size: .zero), animated: true)
            } else {
                self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
            }
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()

        self.scrollView.frame = self.bounds
        
        guard let zoomView = self.viewForZooming(in: self.scrollView) else {
            return
        }
        
        guard self.zoomViewInitialSize.width > 0 && self.zoomViewInitialSize.height > 0 else {
            return
        }
        
        var zoomSize = self.fitSize(self.zoomViewInitialSize, targetSize: self.bounds.size)
        zoomSize.width *= self.scrollView.zoomScale
        zoomSize.height *= self.scrollView.zoomScale
        
        self.scrollView.contentSize = .init(width: max(self.bounds.width, zoomSize.width),
                                            height: max(self.bounds.height, zoomSize.height))
        
        let origin: CGPoint = .init(x: (max(self.scrollView.contentSize.width, self.bounds.width) - zoomSize.width) / 2,
                                    y: (max(self.scrollView.contentSize.height, self.bounds.height) - zoomSize.height) / 2)
        
        zoomView.frame = .init(origin: origin, size: zoomSize)
    }
    
    func fitSize(_ size: CGSize, targetSize: CGSize) -> CGSize {
        let ratio = min(targetSize.width / size.width, targetSize.height / size.height)
        let newSize = CGSize.init(width: Int(size.width * ratio), height: Int(size.height * ratio))
        return newSize
    }
    
    func isCanZoom() -> Bool {
        
        guard self.viewForZooming(in: self.scrollView) != nil else {
            return false
        }
        
        guard self.zoomViewInitialSize.width > 0 && self.zoomViewInitialSize.height > 0 else {
            return false
        }
        
        return true
    }
    
    // MARK: - UIScrollViewDelegate
    open func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if self.isCanZoom() {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
}
