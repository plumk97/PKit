//
//  PKUIMediaBrowserAnimatedTransitioning.swift
//  PKit
//
//  Created by Plumk on 2023/8/15.
//

import UIKit


open class PKUIMediaBrowserAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

    let isDismiss: Bool
    
    init(isDismiss: Bool) {
        self.isDismiss = isDismiss
        super.init()
    }
    
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        // 获取browser
        let browser: PKUIMediaBrowser
        if let vc = transitionContext.viewController(forKey: .to) as? PKUIMediaBrowser {
            browser = vc
        } else if let vc = transitionContext.viewController(forKey: .from) as? PKUIMediaBrowser {
            browser = vc
        } else {
            transitionContext.completeTransition(true)
            return
        }
        
        // 添加view
        if !self.isDismiss {
            let fromView = transitionContext.view(forKey: .from)
            let toView = transitionContext.view(forKey: .to)
            
            if let fromView = fromView {
                containerView.addSubview(fromView)
            }
            
            if let toView = toView {
                containerView.addSubview(toView)
            }
        }
        
        
        if self.isDismiss {
            self.executeDismissAnimation(browser: browser, containerView: containerView) {
                transitionContext.completeTransition(true)
            }
        } else {
            self.executePresentAnimation(browser: browser, containerView: containerView) {
                transitionContext.completeTransition(true)
            }
        }
    }
    
    func fitSize(_ size: CGSize, targetSize: CGSize) -> CGSize {
        let ratio = min(targetSize.width / size.width, targetSize.height / size.height)
        let newSize = CGSize.init(width: Int(size.width * ratio), height: Int(size.height * ratio))
        return newSize
    }
    
    
    func executePresentAnimation(browser: PKUIMediaBrowser, containerView: UIView, complete: @escaping () -> Void) {
        let duration = self.transitionDuration(using: nil)
        
        guard let fromImageView = browser.fromImageView, fromImageView.image != nil else {
            browser.view.alpha = 0
            UIView.animate(withDuration: duration, animations: {
                browser.view.alpha = 1
            }) { (_) in
                complete()
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
        browser.view.alpha = 0
        
        UIView.animate(withDuration: duration, animations: {
            snapshotView.frame = toRect
            browser.view.alpha = 1
        }) { (_) in
            browser.collectionView.isHidden = false
            snapshotView.removeFromSuperview()
            complete()
        }
    }
    
    func executeDismissAnimation(browser: PKUIMediaBrowser, containerView: UIView, complete: @escaping () -> Void) {
        let duration = self.transitionDuration(using: nil)
        
        guard let transitioningView = browser.currentBrowserPage()?.transitioningView,
              let fromView = browser.fromImageView else {
            UIView.animate(withDuration: duration) {
                browser.view.alpha = 0
            } completion: { _ in
                complete()
            }

            return
        }
        
        transitioningView.frame = containerView.convert(transitioningView.frame, from: transitioningView.superview)
        containerView.addSubview(transitioningView)
        
        transitioningView.clipsToBounds = fromView.clipsToBounds
        transitioningView.contentMode = fromView.contentMode
        transitioningView.layer.cornerRadius = fromView.layer.cornerRadius
        
        
        let toRect = containerView.convert(fromView.frame, from: fromView.superview)
        
        UIView.animate(withDuration: duration) {
            
            browser.view.backgroundColor = UIColor.black.withAlphaComponent(0)
            browser.pageTipsLabel.alpha = 0
            transitioningView.frame = toRect
            
        } completion: { _ in
            complete()
        }

        
    }
}
