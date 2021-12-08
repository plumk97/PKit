//
//  PLRippleAnimate.swift
//  PLKit
//
//  Created by Plumk on 2019/4/23.
//  Copyright © 2019 Plumk. All rights reserved.
//

import UIKit

open class PLRippleAnimate: NSObject {
    public enum Style {
        case fill
        case stroke
    }
    
    open var animateNumber: Int! {
        didSet {
            self.makeLayers()
            self.updateLayers()
            self.restartAnimation()
        }
    }
    open private(set) var animateLayers = [CAShapeLayer]()
    
    open var animateDuration: TimeInterval! {
        didSet {
            self.restartAnimation()
        }
    }
    
    open var color: UIColor = .blue {
        didSet {
            self.updateLayers()
        }
    }
    
    open var fromScale: CGFloat = 1.0 {
        didSet {
            self.restartAnimation()
        }
    }
    
    open var toScale: CGFloat = 1.4 {
        didSet {
            self.restartAnimation()
        }
    }
    
    open var fromAlpha: Float = 1 {
        didSet {
            self.restartAnimation()
        }
    }
    
    open var toAlpha: Float = 0 {
        didSet {
            self.restartAnimation()
        }
    }
    
    open var cornerRadius: CGFloat = 0 {
        didSet {
            self.updateLayers()
        }
    }
    
    open var style: Style = .fill {
        didSet {
            self.updateLayers()
        }
    }
    
    open private(set) var isRunning: Bool = false
    
    private var preViewFrame: CGRect = .zero
    open private(set) weak var view: UIView?
    public init(view: UIView, number: Int = 3, duration: TimeInterval = 5) {
        super.init()
        
        self.animateNumber = number
        self.animateDuration = duration
        
        self.view = view
        self.makeLayers()
        self.preViewFrame = self.view!.frame
        self.updateLayers()
        
        /// 监听loop 更新self
        let observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault()?.takeUnretainedValue(), CFRunLoopActivity.beforeWaiting.rawValue, true, 0) { (observer, activity) in
            if activity.rawValue == CFRunLoopActivity.beforeWaiting.rawValue {
                
                if self.view == nil {
                    if CFRunLoopObserverIsValid(observer) {
                        self.releaseLayers()
                    }
                    
                    CFRunLoopObserverInvalidate(observer)
                    CFRunLoopRemoveObserver(CFRunLoopGetMain(), observer, CFRunLoopMode.commonModes)
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
            if layer.superlayer != nil {
                layer.removeFromSuperlayer()
            }
        }
        self.animateLayers.removeAll()
    }
    
    private func makeLayers() {
        self.releaseLayers()
        
        for _ in 0 ..< self.animateNumber {
            let layer = CAShapeLayer()
            layer.isHidden = true
            layer.lineWidth = 1
            
            self.view?.superview?.layer.insertSublayer(layer, below: self.view?.layer)
            self.animateLayers.append(layer)
        }
    }
    
    private func updateLayers() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.animateLayers.forEach { (layer) in
            layer.bounds = self.view!.bounds
            layer.position = self.view!.center
            
            var path: UIBezierPath!
            if self.cornerRadius <= 0 {
                path = UIBezierPath.init(roundedRect: self.view!.bounds, cornerRadius: self.view!.layer.cornerRadius)
            } else {
                path = UIBezierPath.init(roundedRect: self.view!.bounds, cornerRadius: self.cornerRadius)
            }
            
            if self.style == .fill {
                layer.fillColor = self.color.cgColor
                layer.strokeColor = UIColor.clear.cgColor
            } else {
                layer.fillColor = UIColor.clear.cgColor
                layer.strokeColor = self.color.cgColor
            }
            
            layer.path = path.cgPath
        }
        CATransaction.commit()
    }
    
    private func restartAnimation() {
        guard self.isRunning else {
            return
        }
        
        let nowtime = CACurrentMediaTime()
        self.animateLayers.enumerated().forEach { (idx, layer) in
            
            layer.transform = CATransform3DScale(CATransform3DIdentity, self.fromScale, self.fromScale, 1)
            
            let scaleAnim = CABasicAnimation.init(keyPath: "transform")
            scaleAnim.toValue = CATransform3DScale(CATransform3DIdentity, self.toScale, self.toScale, 1)
            
            let alphaAnim = CABasicAnimation.init(keyPath: "opacity")
            alphaAnim.toValue = self.toAlpha
            alphaAnim.fromValue = self.fromAlpha
            
            
            let group = CAAnimationGroup()
            group.animations = [scaleAnim, alphaAnim]
            group.duration = self.animateDuration
            
            
            group.beginTime = nowtime + CFTimeInterval(idx) * (self.animateDuration / CFTimeInterval(self.animateNumber))
            group.repeatCount = Float.greatestFiniteMagnitude
            group.isRemovedOnCompletion = false
            layer.add(group, forKey: nil)
            
            layer.isHidden = false
        }
    }
    
    open func startAnimation() {
        
        guard self.isRunning == false else {
            return
        }
        self.isRunning = true
        self.restartAnimation()
    }
    
    open func stopAnimation() {
        
        guard self.isRunning else {
            return
        }
        self.isRunning = false
        self.animateLayers.forEach { (layer) in
            layer.removeAllAnimations()
            layer.isHidden = true
            layer.transform = CATransform3DScale(CATransform3DIdentity, self.fromScale, self.fromScale, 1)
            layer.opacity = 1
        }
    }
}

fileprivate var kPLRippleAnimate = "PLRippleAnimate"
extension PL where Base: UIView {
    
    public var rippleAnimate: PLRippleAnimate {
        
        var obj = objc_getAssociatedObject(self.base, &kPLRippleAnimate) as? PLRippleAnimate
        if obj == nil {
            obj = PLRippleAnimate.init(view: self.base)
            objc_setAssociatedObject(self.base, &kPLRippleAnimate, obj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return obj!
    }
}
