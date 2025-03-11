//
//  PKUIMediaBrowserImagePage.swift
//  PKit
//
//  Created by Plumk on 2023/12/11.
//

import UIKit
import Photos


open class PKUIMediaBrowserImagePage: PKUIMediaBrowserZoomPage {

    ///
    public let imageView = UIImageView()
    
    /// 
    open override var transitioningView: UIView? { self.imageView }
    
    public override func commInit() {
        super.commInit()
        self.scrollView.addSubview(self.imageView)
    }
    
    open override var zoomViewInitialSize: CGSize {
        return self.imageView.image?.size ?? .zero
    }
    
    open override func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    open override func setMedia(_ media: PKUIMedia) {
        super.setMedia(media)
        
        if let thumbnail = media.pk_thumbnail {
            media.parseImageData(data: thumbnail) {[weak self] image in
                DispatchQueue.main.async {
                    if self?.imageView.image == nil {
                        self?.imageView.image = image
                    }
                }
            }
        }
        
        if let data = media.pk_data {
            media.parseImageData(data: data) {[weak self] image in
                DispatchQueue.main.async {
                    self?.imageView.image = image
                    self?.setNeedsLayout()
                }
            }
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
}
