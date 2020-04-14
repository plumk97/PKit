//
//  PLDot.swift
//  PLKit
//
//  Created by iOS on 2019/8/13.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class PLDot: UIImageView {
    enum Position {
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
    
    
    private var oldSize: CGSize = .zero
    private var oldSuperViewFrame: CGRect = .zero
    
    override var image: UIImage? {
        didSet {
            self.backgroundColor = .clear
            self.holdRound = false
            self.sizeToFit()
        }
    }
    
    var holdRound = true { didSet { self.setNeedsLayout() } }
    var offset: CGPoint = .zero{
        didSet {
            self.oldSize = .zero
            self.reposition()
        }
    }
    
    var position = Position.rightTop {
        didSet {
            self.oldSize = .zero
            self.reposition()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commInit()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        self.commInit()
    }
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        self.commInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func commInit() {
        self.clipsToBounds = true
        self.isHidden = true
        
        /// 监听loop 更新self
        let observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault()?.takeUnretainedValue(), CFRunLoopActivity.allActivities.rawValue, true, 0) {[weak self] (observer, activity) in
            if activity.rawValue == CFRunLoopActivity.beforeWaiting.rawValue {
                
                if self == nil {
                    CFRunLoopRemoveObserver(CFRunLoopGetMain(), observer, CFRunLoopMode.commonModes)
                    CFRunLoopObserverInvalidate(observer)
                } else {
                    self?.reposition()
                }
            }
        }
        CFRunLoopAddObserver(CFRunLoopGetMain(), observer, CFRunLoopMode.commonModes)
    }
  
    
    fileprivate func reposition() {
        guard let sv = self.layer.superlayer else {
            return
        }
        
        
        guard !(self.oldSize.equalTo(self.frame.size) && self.oldSuperViewFrame.equalTo(sv.frame)) else {
            return
        }

        self.oldSize = self.frame.size
        self.oldSuperViewFrame = sv.frame
        
        let svSize = sv.bounds.size
        var frame = self.frame
        switch position {
        case .leftTop:
            frame.origin = .zero
        case .leftMiddle:
            frame.origin = .init(x: 0, y: (svSize.height - frame.height) / 2)
        case .leftBottom:
            frame.origin = .init(x: 0, y: svSize.height - frame.height)
            
        case .middleTop:
            frame.origin = .init(x: (svSize.width - frame.width) / 2, y: 0)
        case .middle:
            frame.origin = .init(x: (svSize.width - frame.width) / 2, y: (svSize.height - frame.height) / 2)
        case .middleBottom:
            frame.origin = .init(x: (svSize.width - frame.width) / 2, y: svSize.height - frame.height)
            
        case .rightTop:
            frame.origin = .init(x: svSize.width - frame.width, y: 0)
        case .rightMiddle:
            frame.origin = .init(x: svSize.width - frame.width, y: (svSize.height - frame.height) / 2)
        case .rightBottom:
            frame.origin = .init(x: svSize.width - frame.width, y: svSize.height - frame.height)
        }
        
        frame.origin.x += offset.x
        frame.origin.y += offset.y
        
        self.frame = frame
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.holdRound {
            layer.cornerRadius = bounds.height / 2
        }
    }
}


fileprivate var kPLDot = "kPLDot"
extension PL where Base: UIView {
    var dot: PLDot {
        return self.base.layer.pl.dot
    }
}

extension PL where Base: CALayer {
    
    var dot: PLDot {
        
        var obj = objc_getAssociatedObject(self.base, &kPLDot) as? PLDot
        if obj == nil {
            obj = PLDot.init(frame: .init(x: 0, y: 0, width: 8, height: 8))
            obj?.backgroundColor = .red
            obj?.holdRound = true
            self.base.addSublayer(obj!.layer)
            obj?.reposition()
            objc_setAssociatedObject(self.base, &kPLDot, obj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return obj!
    }
}
