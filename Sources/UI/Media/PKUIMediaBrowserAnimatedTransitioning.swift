//
//  PKUIMediaBrowserAnimatedTransitioning.swift
//  PKit
//
//  Created by Plumk on 2023/8/15.
//

import UIKit

// MARK: - UIViewControllerTransitioningDelegate
open class PKUIMediaBrowserAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        containerView.frame = UIScreen.main.bounds
        
        // 获取view
        guard let browser: PKUIMediaBrowser = transitionContext.viewController(forKey: .to) as? PKUIMediaBrowser else {
            transitionContext.completeTransition(true)
            return
        }
        
        // 添加view
        let anotherView = transitionContext.view(forKey: .from)
        let browserView = transitionContext.view(forKey: .to)
        
        if let anotherView = anotherView {
            containerView.addSubview(anotherView)
        }
        
        if let browserView = browserView {
            containerView.addSubview(browserView)
        }

        // -- 动画
        let duration = self.transitionDuration(using: nil)
        guard let fromImageView = browser.fromImageView, fromImageView.image != nil else {
            browserView?.alpha = 0
            UIView.animate(withDuration: duration, animations: {
                browserView?.alpha = 1
            }) { (_) in
                transitionContext.completeTransition(true)
            }
            return
        }
        
        let snapshotView = UIImageView.init(image: fromImageView.image)
        snapshotView.contentMode = fromImageView.contentMode
        snapshotView.clipsToBounds = true

        let fromRect = fromImageView.superview?.convert(fromImageView.frame, to: browser.view) ?? snapshotView.frame
        snapshotView.frame = fromRect
        containerView.addSubview(snapshotView)


        let imageSize = fromImageView.image!.size
        let targetSize = browser.view.frame.size
        var toRect = snapshotView.frame
        
        toRect.size = self.fitSize(imageSize, targetSize: targetSize)

        toRect.origin.x = (targetSize.width - toRect.width) / 2
        toRect.origin.y = (targetSize.height - toRect.height) / 2


        browser.collectionView.isHidden = true
        browserView?.alpha = 0

        UIView.animate(withDuration: duration, animations: {
            snapshotView.frame = toRect
            browserView?.alpha = 1
        }) { (_) in
            browser.collectionView.isHidden = false
            snapshotView.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
        
    }
    
    func fitSize(_ size: CGSize, targetSize: CGSize) -> CGSize {
        let ratio = min(targetSize.width / size.width, targetSize.height / size.height)
        let newSize = CGSize.init(width: Int(size.width * ratio), height: Int(size.height * ratio))
        return newSize
    }
}
