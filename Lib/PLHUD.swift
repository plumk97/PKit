//
//  PLHUD.swift
//  PLKit
//
//  Created by iOS on 2019/8/10.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class PLHUD: UIView {
    
    /// 可以保存一些附带信息
    var userInfo: Any?
    
    var style = Style()
    
    var text: String? {
        didSet {
            self.textLabel?.text = text
            self.recalculateFrame()
        }
    }
    
    var attributedText: NSAttributedString? {
        didSet {
            self.textLabel?.attributedText = attributedText
            self.recalculateFrame()
        }
    }
    
    private(set) var inView: UIView?
    private(set) var warpView: UIView?
    private(set) var textLabel: UILabel?
    
    convenience init(_ text: String) {
        self.init(frame: .zero)
        self.text = text
    }
    
    convenience init(_ attributedText: NSAttributedString) {
        self.init(frame: .zero)
        self.attributedText = attributedText
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commInit()
    }
    
    required init?(coder: NSCoder) {
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
    
    func show(_ inView: UIView? = nil) {
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
    
    func hide() {
        UIView.animate(withDuration: 0.15, animations: {
            self.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
}

extension PLHUD {
    struct Style {
        
        // - view
        var maskColor: UIColor = UIColor.clear
        var warpBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.5)
        
        var cornerRadius: CGFloat = 10
        var borderColor: UIColor?
        var borderWidth: CGFloat = 0
        
        var minimumSideSpacing: CGFloat = 15
        var contentInset: UIEdgeInsets = .init(top: -10, left: -13, bottom: -10, right: -13)
        
        // - text
        var color: UIColor = .white
        var font: UIFont = .systemFont(ofSize: 14)
        var alignment: NSTextAlignment = .left
        
        // - show
        var duration: TimeInterval = 1
    }
}
