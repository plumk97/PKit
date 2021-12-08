//
//  PLHUD.swift
//  PLKit
//
//  Created by Plumk on 2019/8/10.
//  Copyright © 2019 Plumk. All rights reserved.
//

import UIKit

open class PLHUD: UIView {
    
    /// 可以保存一些附带信息
    open var userInfo: Any?
    
    open var style = Style()
    
    open var text: String? {
        didSet {
            self.textLabel?.text = text
            self.recalculateFrame()
        }
    }
    
    open var attributedText: NSAttributedString? {
        didSet {
            self.textLabel?.attributedText = attributedText
            self.recalculateFrame()
        }
    }
    
    open private(set) var inView: UIView?
    open private(set) var warpView: UIView?
    open private(set) var textLabel: UILabel?
    
    public convenience init(_ text: String) {
        self.init(frame: .zero)
        self.text = text
    }
    
    public convenience init(_ attributedText: NSAttributedString) {
        self.init(frame: .zero)
        self.attributedText = attributedText
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commInit()
    }
    
    private func commInit() {
        // 一直置顶
        let observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault()?.takeUnretainedValue(), CFRunLoopActivity.beforeWaiting.rawValue, true, 0) {[weak self] (observer, activity) in
            if activity.rawValue == CFRunLoopActivity.beforeWaiting.rawValue {
                
                if self == nil {
                    CFRunLoopObserverInvalidate(observer)
                    CFRunLoopRemoveObserver(CFRunLoopGetMain(), observer, CFRunLoopMode.commonModes)
                } else {
                    guard let superview = self?.superview else {
                        return
                    }
                    if superview.subviews.last != self {
                        superview.bringSubviewToFront(self!)
                    }
                }
            }
        }
        CFRunLoopAddObserver(CFRunLoopGetMain(), observer, CFRunLoopMode.commonModes)
    }
    
    private func setup() {
        
        self.backgroundColor = style.maskColor
        
        let warpView = UIView()
        warpView.backgroundColor = style.warpBackgroundColor
        warpView.layer.cornerRadius = style.cornerRadius
        warpView.layer.borderColor = style.borderColor?.cgColor
        warpView.layer.borderWidth = style.borderWidth
        self.addSubview(warpView)
        
        let textLabel = UILabel()
        textLabel.textAlignment = style.alignment
        textLabel.numberOfLines = 0
        warpView.addSubview(textLabel)
        
        if let text = self.text {
            
            textLabel.text = text
            textLabel.font = style.font
            textLabel.textColor = style.color
        } else if let attributedText = self.attributedText {
            textLabel.attributedText = attributedText
        }
        
        self.warpView = warpView
        self.textLabel = textLabel
    }
    
    private func recalculateFrame() {
        guard let warpView = self.warpView, let textLabel = self.textLabel, let inView = self.inView else {
            return
        }
        
        self.frame = inView.bounds
        
        // - 限制大小
        let limitSize = CGSize.init(width: inView.frame.width - style.minimumSideSpacing * 2 + (style.contentInset.left + style.contentInset.right),
                                    height: inView.frame.height - style.minimumSideSpacing * 2 + (style.contentInset.top + style.contentInset.bottom))
        
        
        var textSize = CGSize.zero
        if let text = self.text {
            textSize = (text as NSString).boundingRect(with: limitSize, options: .usesLineFragmentOrigin, attributes: [.font: style.font], context: nil).size
        } else if let attributedText = self.attributedText {
            textSize = attributedText.boundingRect(with: limitSize, options: .usesLineFragmentOrigin, context: nil).size
        }
        
        warpView.frame.size = textSize
        warpView.frame.origin = .init(x: (self.frame.width - warpView.frame.width) / 2,
                                      y: (self.frame.height - warpView.frame.height) / 2)
        warpView.frame = warpView.frame.inset(by: style.contentInset)
        
        textLabel.frame.size = textSize
        textLabel.frame.origin = .init(x: (warpView.frame.width - textSize.width) / 2,
                                       y: (warpView.frame.height - textSize.height) / 2)
    }
    
    open func show(_ inView: UIView? = nil) {
        if let view = inView ?? UIApplication.shared.delegate?.window! {
            self.isUserInteractionEnabled = true
            self.inView = view
            self.setup()
            self.recalculateFrame()
            
            self.alpha = 0
            view.addSubview(self)
            
            UIView.animate(withDuration: 0.15, animations: {
                self.alpha = 1
            }) { (_) in
                if self.style.duration > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.style.duration) {
                        self.hide()
                    }
                }
            }
        }
    }
    
    open func hide() {
        UIView.animate(withDuration: 0.15, animations: {
            self.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
}

extension PLHUD {
    public struct Style {
        
        // - view
        public var maskColor: UIColor = UIColor.clear
        public var warpBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.5)
        
        public var cornerRadius: CGFloat = 10
        public var borderColor: UIColor?
        public var borderWidth: CGFloat = 0
        
        public var minimumSideSpacing: CGFloat = 15
        public var contentInset: UIEdgeInsets = .init(top: -10, left: -13, bottom: -10, right: -13)
        
        // - text
        public var color: UIColor = .white
        public var font: UIFont = .systemFont(ofSize: 14)
        public var alignment: NSTextAlignment = .left
        
        // - show
        public var duration: TimeInterval = 1
    }
}
