//
//  PKUIDot.swift
//  PKit
//
//  Created by Plumk on 2019/8/13.
//  Copyright © 2019 Plumk. All rights reserved.
//

import UIKit

open class PKUIDot: UIImageView {
    
    public enum Position {
        case leftTop
        case leftMiddle
        case leftBottom
        
        case middleTop
        case middle
        case middleBottom
        
        case rightTop
        case rightMiddle
        case rightBottom
    }
    
    
    
    open override var image: UIImage? {
        didSet {
            self.sizeToFit()
        }
    }
    
    open var alwayHalfRadius = true {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    open var offset: CGPoint = .zero{
        didSet {
            self.updatePosition(force: true)
        }
    }
    
    open var position = Position.rightTop {
        didSet {
            self.updatePosition(force: true)
        }
    }
    
    ///
    var lastSuperlayerBounds: CGRect = .zero
    
    ///
    var lastBounds: CGRect = .zero
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commInit()
    }
    
    public override init(image: UIImage?) {
        super.init(image: image)
        self.commInit()
    }
    
    public override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        self.commInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func commInit() {
        self.clipsToBounds = true
        self.isHidden = true
        
        /// 监听loop 更新self
        let observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault()?.takeUnretainedValue(), CFRunLoopActivity.beforeWaiting.rawValue, true, 0) {[weak self] (observer, activity) in
            if activity.rawValue == CFRunLoopActivity.beforeWaiting.rawValue {
                
                if self == nil {
                    CFRunLoopObserverInvalidate(observer)
                    CFRunLoopRemoveObserver(CFRunLoopGetMain(), observer, CFRunLoopMode.commonModes)
                } else {
                    self?.updatePosition()
                }
            }
        }
        CFRunLoopAddObserver(CFRunLoopGetMain(), observer, CFRunLoopMode.commonModes)
    }
  
    
    func updatePosition(force: Bool = false) {
        guard let superlayer = self.superview?.layer ?? self.layer.superlayer else {
            return
        }
        
        if !force {
            guard !self.lastSuperlayerBounds.equalTo(superlayer.bounds) || !self.lastBounds.equalTo(self.bounds) else {
                return
            }
        }
        self.lastSuperlayerBounds = superlayer.bounds
        self.lastBounds = self.bounds
        
        let superBounds = superlayer.bounds
        var frame = self.frame
        switch position {
        case .leftTop:
            frame.origin = .zero
        case .leftMiddle:
            frame.origin = .init(x: 0, y: (superBounds.height - frame.height) / 2)
        case .leftBottom:
            frame.origin = .init(x: 0, y: superBounds.height - frame.height)
            
        case .middleTop:
            frame.origin = .init(x: (superBounds.width - frame.width) / 2, y: 0)
        case .middle:
            frame.origin = .init(x: (superBounds.width - frame.width) / 2, y: (superBounds.height - frame.height) / 2)
        case .middleBottom:
            frame.origin = .init(x: (superBounds.width - frame.width) / 2, y: superBounds.height - frame.height)
            
        case .rightTop:
            frame.origin = .init(x: superBounds.width - frame.width, y: 0)
        case .rightMiddle:
            frame.origin = .init(x: superBounds.width - frame.width, y: (superBounds.height - frame.height) / 2)
        case .rightBottom:
            frame.origin = .init(x: superBounds.width - frame.width, y: superBounds.height - frame.height)
        }
        
        frame.origin.x += offset.x
        frame.origin.y += offset.y
        
        self.frame = frame
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if self.alwayHalfRadius {
            self.layer.cornerRadius = self.bounds.height / 2
        }
    }
}

// MARK: -
fileprivate var kPKUIDot = "kPKUIDot"
extension PK where Base: UIView {
    public var dot: PKUIDot {
        return self.base.layer.pk.dot
    }
}

extension PK where Base: CALayer {
    
    public var dot: PKUIDot {
        
        var obj = objc_getAssociatedObject(self.base, &kPKUIDot) as? PKUIDot
        if obj == nil {
            obj = PKUIDot.init(frame: .init(x: 0, y: 0, width: 8, height: 8))
            obj?.backgroundColor = .red
            obj?.alwayHalfRadius = true
            self.base.addSublayer(obj!.layer)
            objc_setAssociatedObject(self.base, &kPKUIDot, obj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return obj!
    }
}

extension PK where Base: UIBarButtonItem {
    public var dot: PKUIDot? {
        if let view = self.base.value(forKey: "view") as? UIView {
            return view.pk.dot
        }
        return nil
    }
}
