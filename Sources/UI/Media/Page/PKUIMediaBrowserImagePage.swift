//
//  PKUIMediaBrowserImagePage.swift
//  PKit
//
//  Created by Plumk on 2023/8/15.
//

import UIKit
import Photos

open class PKUIMediaBrowserImagePage: PKUIMediaBrowserZoomPage {

    
    let imageView = UIImageView()
    open override func commInit() {
        super.commInit()
        
        if let asset = self.media.pk_data as? PHAsset {
            let op = PHImageRequestOptions()
            op.deliveryMode = .highQualityFormat
            PHImageManager.default().requestImage(for: asset, targetSize: .zero, contentMode: .default, options: op) { (image, _) in
                DispatchQueue.main.async {
                    self.imageView.image = image
                    self.setNeedsLayout()
                }
            }
        } else {
            self.imageView.image = UIImage(named: "tabbar_guanxuan_selected")
        }
        
        self.scrollView.addSubview(self.imageView)
    }
    
    open override func closePanProgressUpdate(progress: CGFloat, beginPoint: CGPoint, offset: CGPoint) {
        let scale = min(1, max(0.6, 1 - progress))
        self.imageView.transform = CGAffineTransform.identity
            .translatedBy(x: offset.x - beginPoint.x, y: offset.y - beginPoint.y)
            .scaledBy(x: scale, y: scale)
    }
    
    open override func closePanEnd(isClosed: Bool, fromView: UIView?, complete: @escaping () -> Void) {
        
        if isClosed {
            
            if let fromView = fromView, let fromRect = fromView.superview?.convert(fromView.frame, to: self) {
                
                self.imageView.contentMode = fromView.contentMode
                self.imageView.clipsToBounds = fromView.clipsToBounds
                self.imageView.layer.cornerRadius = fromView.layer.cornerRadius
                
                UIView.animate(withDuration: 0.25) {
                    self.imageView.frame = fromRect
                } completion: { isOk in
                    complete()
                }

            } else {
                UIView.animate(withDuration: 0.25) {
                    self.imageView.alpha = 0
                } completion: { isOk in
                    complete()
                }
            }
            
            
        } else {
            UIView.animate(withDuration: 0.25) {
                self.imageView.transform = .identity
            } completion: { isOk in
                complete()
            }
        }
        
        

    }
    
    open override var zoomViewInitialSize: CGSize {
        return self.imageView.image?.size ?? .zero
    }
    
    open override func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
