//
//  PKUIArrangeView.swift
//  PKit
//
//  Created by Plumk on 2020/4/2.
//  Copyright © 2020 Plumk. All rights reserved.
//

import UIKit

open class PKUIArrangeView: UIView {
    public enum Axis {
        case horizontal
        case vertical
    }
    
    /// 布局方向
    open var direction = Axis.horizontal {
        didSet {
            self.setNeedsLayout()
        }
    }
    /// 当前方向间距
    open var mainAxisSpacing: CGFloat = 0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// 反方向间距 横向则是纵向间距 纵向则是横向间距
    open var crossAxisSpacing: CGFloat = 0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// 限制多少行0不限制
    open var lineNumber: UInt = 0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    open var views = [UIView]() {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    private var innerContentSize: CGSize = .zero
    
    public init(_ views: [UIView]? = nil, direction: Axis? = nil, mainAxisSpacing: CGFloat? = nil, crossAxisSpacing: CGFloat? = nil, lineNumber: UInt? = nil) {
        super.init(frame: .zero)
        
        if let x = views {
            self.views = x
        }
        
        if let x = direction {
            self.direction = x
        }

        
        if let x = mainAxisSpacing {
            self.mainAxisSpacing = x
        }
        
        if let x = crossAxisSpacing {
            self.crossAxisSpacing = x
        }
        
        if let x = lineNumber {
            self.lineNumber = x
        }
        
        self.commInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commInit()
    }
    
    
    private func commInit() {
        self.clipsToBounds = true
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        var tmpInnerContentSize: CGSize = .zero
        defer {
            if !tmpInnerContentSize.equalTo(self.innerContentSize) {
                self.innerContentSize = tmpInnerContentSize
                self.invalidateIntrinsicContentSize()
            }
        }
        
        switch self.direction {
        case .horizontal:
            
            var origin: CGPoint = .zero
            var maxHeight: CGFloat = 0
            
            var lines = 0
            for view in self.views {
                if view.superview != self {
                    if view.superview != nil {
                        view.removeFromSuperview()
                    }
                    self.addSubview(view)
                }
                
                if view.frame.size.equalTo(.zero) {
                    view.frame.size = view.intrinsicContentSize
                }
                
                if view.frame.size.equalTo(.zero) {
                    view.sizeToFit()
                }
                
                
                
                if origin.x + view.frame.width > self.frame.width {
                    lines += 1
                    if lines >= self.lineNumber && self.lineNumber > 0 {
                        break
                    }
                    
                    origin.y = origin.y + maxHeight + self.crossAxisSpacing
                    origin.x = 0
                }
                
                
                view.frame.origin = origin
                origin.x = view.frame.maxX + self.mainAxisSpacing
                maxHeight = max(view.frame.height, maxHeight)
            }
            
            tmpInnerContentSize = .init(width: self.frame.width, height: origin.y + maxHeight)
            
        case .vertical:
            
            var origin: CGPoint = .zero
            var maxWidth: CGFloat = 0
            
            var lines = 0
            for view in self.views {
                if view.superview != self {
                    if view.superview != nil {
                        view.removeFromSuperview()
                    }
                    self.addSubview(view)
                }
                
                if view.frame.size.equalTo(.zero) {
                    view.frame.size = view.intrinsicContentSize
                }
                
                if view.frame.size.equalTo(.zero) {
                    view.sizeToFit()
                }
                
                
                
                if origin.y + view.frame.height > self.frame.height {
                    lines += 1
                    if lines >= self.lineNumber && self.lineNumber > 0 {
                        break
                    }
                    
                    origin.x = origin.x + maxWidth + self.crossAxisSpacing
                    origin.y = 0
                }
                
                
                view.frame.origin = origin
                origin.y = view.frame.maxY + self.mainAxisSpacing
                maxWidth = max(view.frame.width, maxWidth)
            }
            
            tmpInnerContentSize = .init(width: origin.x + maxWidth, height: self.frame.height)
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        return self.innerContentSize
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        return self.innerContentSize
    }
    override open func sizeToFit() {
        self.layoutIfNeeded()
        super.sizeToFit()
    }
}

