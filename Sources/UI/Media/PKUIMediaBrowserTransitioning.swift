//
//  PKUIMediaBrowserTransitioning.swift
//  PKit
//
//  Created by Plumk on 2023/12/11.
//

import Foundation

class PKUIMediaBrowserTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

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
    
    
    func createViewThumbImage(view: UIView) -> UIImage? {
        
        if let imageView = view as? UIImageView {
            return imageView.image
        }
        
        let render = UIGraphicsImageRenderer(size: view.bounds.size)
        return  render.image { ctx in
            view.layer.render(in: ctx.cgContext)
        }
    }
    
    
    func executePresentAnimation(browser: PKUIMediaBrowser, containerView: UIView, complete: @escaping () -> Void) {
        let duration = self.transitionDuration(using: nil)
        
        guard let fromView = browser.transitioningView?(browser), let fromImage = self.createViewThumbImage(view: fromView) else {
            browser.view.alpha = 0
            UIView.animate(withDuration: duration, animations: {
                browser.view.alpha = 1
            }) { (_) in
                complete()
            }
            return
        }
        

        let snapshotView = UIImageView.init(image: fromImage)
        snapshotView.contentMode = fromView.contentMode
        snapshotView.clipsToBounds = true

        let fromRect = fromView.superview?.convert(fromView.frame, to: browser.view) ?? snapshotView.frame
        snapshotView.frame = fromRect
        containerView.addSubview(snapshotView)


        let imageSize = fromImage.size
        let targetSize = browser.view.frame.size
        var toRect = snapshotView.frame

        
        toRect.size = imageSize.fitSize(targetSize: targetSize)

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
        
        
        guard let cell = browser.collectionView.cellForItem(at: .init(row: browser.currentPageIndex, section: 0)) as? PKUIMediaBrowserCell,
              let transitioningView = cell.page?.transitioningView,
              let snapshotView = transitioningView.snapshotView(afterScreenUpdates: true),
              let toView = browser.transitioningView?(browser) else {
            
            UIView.animate(withDuration: duration) {
                browser.view.alpha = 0
            } completion: { _ in
                complete()
            }
            return
        }
        
        
        snapshotView.frame = containerView.convert(transitioningView.frame, from: transitioningView.superview)
        containerView.addSubview(snapshotView)
        
        snapshotView.clipsToBounds = toView.clipsToBounds
        snapshotView.contentMode = toView.contentMode
        snapshotView.layer.cornerRadius = toView.layer.cornerRadius
        
        
        let toRect = containerView.convert(toView.frame, from: toView.superview)
        browser.collectionView.isHidden = true
        UIView.animate(withDuration: duration) {
            
            browser.view.backgroundColor = UIColor.black.withAlphaComponent(0)
            snapshotView.frame = toRect
            
        } completion: { _ in
            complete()
        }

        
    }
}
