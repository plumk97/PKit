//
//  PLRippleAnimate.swift
//  PLKit
//
//  Created by iOS on 2019/4/23.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class PLRippleAnimate: NSObject {
    
    private(set) var animateNumber: Int!
    private(set) var animateDuration: TimeInterval!
    private(set) var animateLayers = [CALayer]()
    var color: UIColor = .blue {
        didSet {
            self.updateLayers()
        }
    }
    
    var scale: CGFloat = 2 {
        didSet {
            self.restartAnimation()
        }
    }
    
    var fromAlpha: Float = 1 {
        didSet {
            self.restartAnimation()
        }
    }
    
    var toAlpha: Float = 0 {
        didSet {
            self.restartAnimation()
        }
    }
    
    var cornerRadius: CGFloat = 0 {
        didSet {
            self.updateLayers()
        }
    }
    
    private(set) var isRunning: Bool = false
    
    private var preViewFrame: CGRect = .zero
    private(set) weak var view: UIView?
    init(view: UIView, number: Int = 3, duration: TimeInterval = 5) {
        super.init()
        
        self.animateNumber = number
        self.animateDuration = duration
        
        self.view = view
        
        for _ in 0 ..< number {
            let layer = CALayer()
            layer.isHidden = true
            view.superview?.layer.insertSublayer(layer, below: self.view?.layer)
            self.animateLayers.append(layer)
        }
        self.preViewFrame = self.view!.frame
        self.updateLayers()
        
        /// 监听loop 更新self
        let observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault()?.takeUnretainedValue(), CFRunLoopActivity.allActivities.rawValue, true, 0) { (observer, activity) in
            if activity.rawValue == CFRunLoopActivity.beforeWaiting.rawValue {
                
                if self.view == nil {
                    CFRunLoopRemoveObserver(CFRunLoopGetMain(), observer, CFRunLoopMode.commonModes)
                    CFRunLoopObserverInvalidate(observer)
                    self.releaseLayers()
                } else {
                    if !(self.view?.frame.equalTo(self.preViewFrame) ?? true) {
                        self.preViewFrame = self.view!.frame
                        self.updateLayers()
                    }
                }
            }
        }
        CFRunLoopAddObserver(CFRunLoopGetMain(), observer, CFRunLoopMode.commonModes)
    }
    
    private func releaseLayers() {
        self.animateLayers.forEach { (layer) in
            layer.removeAllAnimations()
            layer.removeFromSuperlayer()
        }
    }
    
    
    private func updateLayers() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.animateLayers.forEach { (layer) in
            layer.frame = self.view!.frame
            if self.cornerRadius <= 0 {
                layer.cornerRadius = self.view!.layer.cornerRadius
            } else {
                layer.cornerRadius = self.cornerRadius
            }
            layer.backgroundColor = self.color.cgColor
        }
        CATransaction.commit()
    }
    
    private func restartAnimation() {
        guard self.isRunning else {
            return
        }
        
        self.animateLayers.enumerated().forEach { (idx, layer) in
            layer.isHidden = false
            
            let scaleAnim = CABasicAnimation.init(keyPath: "transform")
            scaleAnim.toValue = CATransform3DScale(CATransform3DIdentity, self.scale, self.scale, 1)
            scaleAnim.fromValue = CATransform3DIdentity
            
            let alphaAnim = CABasicAnimation.init(keyPath: "opacity")
            alphaAnim.toValue = self.toAlpha
            alphaAnim.fromValue = self.fromAlpha
            
            
            let group = CAAnimationGroup()
            group.animations = [scaleAnim, alphaAnim]
            group.duration = self.animateDuration
            
            group.beginTime = CACurrentMediaTime() + CFTimeInterval(idx) * (self.animateDuration * 0.25)
            group.repeatCount = Float.greatestFiniteMagnitude
            group.isRemovedOnCompletion = false
            layer.add(group, forKey: nil)
        }
    }
    
    func startAnimation() {
        
        guard self.isRunning == false else {
            return
        }
        self.isRunning = true
        self.restartAnimation()
    }
    
    func stopAnimation() {
        
        guard self.isRunning else {
            return
        }
        self.isRunning = false
        self.animateLayers.forEach { (layer) in
            layer.removeAllAnimations()
            layer.isHidden = true
            layer.transform = CATransform3DIdentity
            layer.opacity = 1
        }
    }
}

fileprivate var kPLRippleAnimate = "PLRippleAnimate"
extension PL where Base: UIView {
    
    var rippleAnimate: PLRippleAnimate {
        
        var obj = objc_getAssociatedObject(self.base, &kPLRippleAnimate) as? PLRippleAnimate
        if obj == nil {
            obj = PLRippleAnimate.init(view: self.base)
            objc_setAssociatedObject(self.base, &kPLRippleAnimate, obj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return obj!
    }
}
