//
//  PLArrangeView.swift
//  PLKit
//
//  Created by Plumk on 2020/4/2.
//  Copyright © 2020 Plumk. All rights reserved.
//

import UIKit

class PLArrangeView: UIView {
    enum Axis {
        case horizontal
        case vertical
    }
    
    /// 布局方向
    var direction = Axis.horizontal {
        didSet {
            self.setNeedsLayout()
        }
    }
    /// 当前方向间距
    var mainAxisSpacing: CGFloat = 0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// 反方向间距 横向则是纵向间距 纵向则是横向间距
    var crossAxisSpacing: CGFloat = 0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    var views = [UIView]() {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    private var innerContentSize: CGSize = .zero
    
    init(_ views: [UIView]? = nil, direction: Axis? = nil, mainAxisSpacing: CGFloat? = nil, crossAxisSpacing: CGFloat? = nil) {
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
        self.commInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commInit()
    }
    
    
    private func commInit() {
        self.clipsToBounds = true
    }
    
    override func layoutSubviews() {
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
    
    override var intrinsicContentSize: CGSize {
        return self.innerContentSize
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return self.innerContentSize
    }
    override func sizeToFit() {
        self.layoutIfNeeded()
        super.sizeToFit()
    }
}

