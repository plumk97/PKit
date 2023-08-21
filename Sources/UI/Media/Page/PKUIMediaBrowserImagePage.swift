//
//  PKUIMediaBrowserImagePage.swift
//  PKit
//
//  Created by Plumk on 2023/8/15.
//

import UIKit
import Photos

open class PKUIMediaBrowserImagePage: PKUIMediaBrowserZoomPage {

    open override var transitioningView: UIView? {
        return self.imageView
    }
    
    ///
    public let imageView = UIImageView()
    
    
    ///
    public let loadingIndicator = UIActivityIndicatorView(style: .white)
    
    /// 长按
    public let longPressGesture = UILongPressGestureRecognizer()
    
    open override func commInit() {
        super.commInit()

        self.scrollView.addSubview(self.imageView)

        self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.loadingIndicator)
        self.loadingIndicator.startAnimating()

        self.addConstraints([
            .init(item: self.loadingIndicator, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: -10),
            .init(item: self.loadingIndicator, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 10)
        ])
        
        self.longPressGesture.addTarget(self, action: #selector(longPressGestureHandle))
        self.addGestureRecognizer(self.longPressGesture)
        
        if let thumbnail = self.media.pk_thumbnail {
            self.media.parseImageData(data: thumbnail) {[weak self] image in
                if self?.imageView.image == nil {
                    self?.imageView.image = image
                    self?.setNeedsLayout()
                }
            }
        }
        
        if let data = self.media.pk_data {
            self.media.parseImageData(data: data) {[weak self] image in
                self?.imageView.image = image
                self?.setNeedsLayout()
                
                self?.loadingIndicator.stopAnimating()
            }
        }
    }
    
    @objc open  func longPressGestureHandle(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began && !self.loadingIndicator.isAnimating {
            guard let image = self.imageView.image else {
                return
            }
            let vc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            
            var presentVc = PKUIWindowGetter.keyWindow?.rootViewController
            while presentVc?.presentedViewController != nil {
                presentVc = presentVc?.presentedViewController
            }
            presentVc?.present(vc, animated: true)
        }
    }

    open override func closePanProgressUpdate(progress: CGFloat, beginPoint: CGPoint, offset: CGPoint) {
        let scale = min(1, max(0.6, 1 - progress))
        self.imageView.transform = CGAffineTransform.identity
            .translatedBy(x: offset.x - beginPoint.x, y: offset.y - beginPoint.y)
            .scaledBy(x: scale, y: scale)
    }
    
    open override func closePanRestore() {
        
        UIView.animate(withDuration: 0.25) {
            self.imageView.transform = .identity
        }
    }
    
    open override var zoomViewInitialSize: CGSize {
        return self.imageView.image?.size ?? .zero
    }
    
    open override func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
