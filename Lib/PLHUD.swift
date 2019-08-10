//
//  PLHUD.swift
//  PLKit
//
//  Created by iOS on 2019/8/10.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class PLHUD: UIView {
    
    let style = Style()
    
    
    var text: String?
    
    
    
    private var inView: UIView?
    private var warpView: UIView!
    
    convenience init(text: String) {
        self.init(frame: .zero)
        self.text = text
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
        warpView.backgroundColor = style.bgColor
        warpView.layer.cornerRadius = style.cornerRadius
        
        // - 限制大小
        let limitSize = CGSize.init(width: inView.frame.width - style.minimumSideSpacing * 2 + (style.contentInset.left + style.contentInset.right),
                                    height: inView.frame.height - style.minimumSideSpacing * 2 + (style.contentInset.top + style.contentInset.bottom))
        
        var contentSize: CGSize = .zero
        if let text = text {
            
            let textSize = (text as NSString).boundingRect(with: limitSize, options: .usesLineFragmentOrigin, attributes: [.font: style.font, .foregroundColor: style.color], context: nil).size
            
            let label = UILabel()
            label.numberOfLines = 0
            label.text = text
            label.font = style.font
            label.textColor = style.color
            label.frame.size = textSize
            warpView.addSubview(label)
            
            contentSize = textSize
        }
        
        
        self.addSubview(warpView)
        warpView.bounds.size = contentSize
        warpView.bounds = warpView.bounds.inset(by: style.contentInset)
        self.updateWarpOrigin()
    }
    
    private func updateWarpOrigin() {
        var frame = warpView.frame
        frame.origin.x = (self.frame.width - frame.width) / 2
        frame.origin.y = (self.frame.height - frame.height) / 2
        warpView.frame = frame
    }
    
    func show(_ inView: UIView? = nil) {
        if let view = inView ?? UIApplication.shared.delegate?.window! {
            self.isUserInteractionEnabled = false
            self.inView = view
            self.setup()
            self.alpha = 0
            view.addSubview(self)
            
            UIView.animate(withDuration: 0.15, animations: {
                self.alpha = 1
            }) { (_) in
                DispatchQueue.main.asyncAfter(deadline: .now() + self.style.duration) {
                    self.hide()
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
        var bgColor: UIColor = UIColor.black.withAlphaComponent(0.8)
        var cornerRadius: CGFloat = 10
        
        var minimumSideSpacing: CGFloat = 15
        var contentInset: UIEdgeInsets = .init(top: -10, left: -10, bottom: -10, right: -10)
        
        // - text
        var color: UIColor = .white
        var font: UIFont = .systemFont(ofSize: 15)
        
        // - show
        var duration: TimeInterval = 1.5
    }
}
