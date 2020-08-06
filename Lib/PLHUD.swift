//
//  PLHUD.swift
//  PLKit
//
//  Created by iOS on 2019/8/10.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class PLHUD: UIView {
    
    var style = Style()
    
    var text: String?
    var attributedText: NSAttributedString?
    
    private(set) var inView: UIView?
    private(set) var warpView: UIView!
    
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
        let observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault()?.takeUnretainedValue(), CFRunLoopActivity.allActivities.rawValue, true, 0) {[weak self] (observer, activity) in
            if activity.rawValue == CFRunLoopActivity.beforeWaiting.rawValue {
                
                if self == nil {
                    CFRunLoopRemoveObserver(CFRunLoopGetMain(), observer, CFRunLoopMode.commonModes)
                    CFRunLoopObserverInvalidate(observer)
                    
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
        
        guard let inView = inView else {
            return
        }
        
        self.frame = inView.bounds
        self.backgroundColor = style.maskColor
        
        warpView = UIView()
        warpView.backgroundColor = style.warpBackgroundColor
        warpView.layer.cornerRadius = style.cornerRadius
        warpView.layer.borderColor = style.borderColor?.cgColor
        warpView.layer.borderWidth = style.borderWidth
        self.addSubview(warpView)
        
        // - 限制大小
        let limitSize = CGSize.init(width: inView.frame.width - style.minimumSideSpacing * 2 + (style.contentInset.left + style.contentInset.right),
                                    height: inView.frame.height - style.minimumSideSpacing * 2 + (style.contentInset.top + style.contentInset.bottom))
        
        let textLabel = UILabel()
        textLabel.numberOfLines = 0
        warpView.addSubview(textLabel)
        
        var textSize: CGSize = .zero
        if let text = self.text {
            
            textLabel.text = text
            textLabel.font = style.font
            textLabel.textColor = style.color
            
            textSize = (text as NSString).boundingRect(with: limitSize, options: .usesLineFragmentOrigin, attributes: [.font: style.font], context: nil).size
            textLabel.frame.size = textSize
            
        } else if let attributedText = self.attributedText {
            
            textLabel.attributedText = attributedText
            
            textSize = attributedText.boundingRect(with: limitSize, options: .usesLineFragmentOrigin, context: nil).size
            textLabel.frame.size = textSize
        }
        
        warpView.bounds.size = textSize
        warpView.bounds = warpView.bounds.inset(by: style.contentInset)
        
        warpView.frame.origin = .init(x: (self.frame.width - warpView.frame.width) / 2,
                                      y: (self.frame.height - warpView.frame.height) / 2)
    }
    
    func show(_ inView: UIView? = nil) {
        if let view = inView ?? UIApplication.shared.delegate?.window! {
            self.isUserInteractionEnabled = true
            self.inView = view
            self.setup()
            
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
        
        // - show
        var duration: TimeInterval = 1
    }
}
