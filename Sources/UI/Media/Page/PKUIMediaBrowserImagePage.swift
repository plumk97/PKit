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
    let imageView = UIImageView()
    
    open override func commInit() {
        super.commInit()
        
        
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
            }
        }
        

        self.scrollView.addSubview(self.imageView)
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
