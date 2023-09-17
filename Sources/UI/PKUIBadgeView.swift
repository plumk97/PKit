//
//  PKUIBadgeView.swift
//  PKit
//
//  Created by Plumk on 2019/6/9.
//  Copyright © 2019 Plumk. All rights reserved.
//

import UIKit

open class PKUIBadgeView: UIView {
    
    open var string: String? {
        didSet {
            self.isHidden = (self.string?.count ?? 0) <= 0
            self.textLabel.text = self.string
            self.invalidateIntrinsicContentSize()
            self.sizeToFit()
        }
    }
    
    ///
    open var offset: CGPoint = .zero {
        didSet {
            self.updatePosition(force: true)
        }
    }
    
    /// 内填充
    open var padding: UIEdgeInsets = .init(top: 2, left: 6, bottom: 2, right: 6)
    
    /// 文字
    open private(set) var textLabel = UILabel()
    
    ///
    var lastSuperlayerBounds: CGRect = .zero
    
    ///
    var lastBounds: CGRect = .zero
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commInit()
    }
    
    private func commInit() {
        self.backgroundColor = .init(red: 1, green: 0.231373, blue: 0.188235, alpha: 1)
        self.layer.masksToBounds = true
        
        if #available(iOS 13.0, *) {
            self.textLabel.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        } else {
            self.textLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        }
        
        self.textLabel.textAlignment = .center
        self.textLabel.textColor = .white
        self.addSubview(self.textLabel)
        
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
        guard let superlayer = self.superview?.layer else {
            return
        }
        
        if !force {
            guard !self.lastSuperlayerBounds.equalTo(superlayer.bounds) || !self.lastBounds.equalTo(self.bounds) else {
                return
            }
        }
        
        self.lastSuperlayerBounds = superlayer.bounds
        self.lastBounds = self.bounds
        
        self.frame.origin = .init(x: superlayer.bounds.width - self.frame.width + self.offset.x,
                                  y: offset.y)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.height / 2
        
        self.textLabel.sizeToFit()
        self.textLabel.frame.origin = .init(x: self.padding.left, y: self.padding.top)
    }
    
    open override var intrinsicContentSize: CGSize {
        return self.sizeThatFits(.zero)
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = self.textLabel.sizeThatFits(.zero)
        size.width += self.padding.left + self.padding.right
        size.height += self.padding.top + self.padding.bottom
        return size
    }
}


// MARK: -
fileprivate var kPKUIBadgeView = "kPKUIBadgeView"
extension PK where Base: UIView {
    public var badge: PKUIBadgeView {
        var obj = objc_getAssociatedObject(self.base, &kPKUIBadgeView) as? PKUIBadgeView
        if obj == nil {
            let badgeView = PKUIBadgeView()
            self.base.addSubview(badgeView)
            objc_setAssociatedObject(self.base, &kPKUIBadgeView, badgeView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            obj = badgeView
        }
        return obj!
    }
}

extension PK where Base: CALayer {
    
    public var badge: PKUIBadgeView {
        
        var obj = objc_getAssociatedObject(self.base, &kPKUIBadgeView) as? PKUIBadgeView
        if obj == nil {
            let badgeView = PKUIBadgeView()
            self.base.addSublayer(badgeView.layer)
            objc_setAssociatedObject(self.base, &kPKUIBadgeView, badgeView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            obj = badgeView
        }
        return obj!
    }
}

extension PK where Base: UIBarButtonItem {
    
    public var badge: PKUIBadgeView? {
        if let view = self.base.value(forKey: "view") as? UIView {
            return view.pk.badge
        }
        return nil
    }
}
