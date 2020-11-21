//
//  PLGridView.swift
//  PLKit
//
//  Created by Plumk on 2020/11/21.
//  Copyright © 2020 Plumk. All rights reserved.
//

import UIKit


/// 根据方向 需要指定宽或高 否则不显示
class PLGridView: UIView {
    enum Axis {
        case horizontal
        case vertical
    }
    
    /// 布局方向
    var direction = Axis.horizontal {
        didSet {
            self.decideIsRelayout()
        }
    }
    
    /// 根据方向指示有多少 行/列 最小为1 0不显示
    var crossAxisCount: Int = 1 {
        didSet {
            self.decideIsRelayout()
        }
    }
    
    /// 当前方向间距
    var mainAxisSpacing: CGFloat = 0 {
        didSet {
            self.decideIsRelayout()
        }
    }
    
    /// 反方向间距 横向则是纵向间距 纵向则是横向间距
    var crossAxisSpacing: CGFloat = 0 {
        didSet {
            self.decideIsRelayout()
        }
    }
    
    /// 宽高比率 横向 height / width 纵向 width / height
    var aspectRatio: CGFloat = 1
    
    var views = [UIView]() {
        didSet {
            self.decideIsRelayout()
        }
    }
    
    private var isNeedRelayout = false
    private var innerContentSize: CGSize = .zero
    
    override var frame: CGRect {
        didSet {
            if !frame.size.equalTo(oldValue.size) {
                self.decideIsRelayout()
            }
        }
    }
    
    init(_ views: [UIView], direction: Axis? = nil, crossAxisCount: Int? = nil, mainAxisSpacing: CGFloat? = nil, crossAxisSpacing: CGFloat? = nil) {
        super.init(frame: .zero)
        self.views = views
        
        if let x = direction {
            self.direction = x
        }
        
        if let x = crossAxisCount {
            self.crossAxisCount = x
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
    
    private func decideIsRelayout() {
        if self.superview == nil {
            self.isNeedRelayout = true
        } else {
            self.relayoutViews()
        }
    }
        
    private func relayoutViews() {
        
        self.isNeedRelayout = false
        self.innerContentSize = .zero
        defer {
            self.invalidateIntrinsicContentSize()
        }
        guard self.crossAxisCount > 0 else {
            return
        }
        
        switch self.direction {
        case .horizontal:
            guard self.frame.width > 0 else {
                return
            }
            self.innerContentSize.width = self.frame.width
            
            var size: CGSize = .zero
            size.width = (self.frame.width - CGFloat(self.crossAxisCount - 1) * self.mainAxisSpacing) / CGFloat(self.crossAxisCount)
            size.height = size.width * self.aspectRatio
            
            var origin: CGPoint = .zero
            for i in 0 ..< self.views.count {
                if i != 0 && i % self.crossAxisCount == 0 {
                    origin.x = 0
                    origin.y = origin.y + size.height + self.crossAxisSpacing
                }
                
                let view = self.views[i]
                
                if view.superview != self {
                    if view.superview != nil {
                        view.removeFromSuperview()
                    }
                    self.addSubview(view)
                }
                
                var rect: CGRect = .zero
                rect.origin = origin
                rect.size = size
                view.frame = rect
                
                origin.x = rect.maxX + self.mainAxisSpacing
            }
            
            self.innerContentSize.height = self.views.last?.frame.maxY ?? 0
            
        case .vertical:
            guard self.frame.height > 0 else {
                return
            }
            self.innerContentSize.height = self.frame.height
            
            var size: CGSize = .zero
            size.height = (self.frame.height - CGFloat(self.crossAxisCount - 1) * self.mainAxisSpacing) / CGFloat(self.crossAxisCount)
            size.width = size.height * self.aspectRatio
            
            var origin: CGPoint = .zero
            for i in 0 ..< self.views.count {
                if i != 0 && i % self.crossAxisCount == 0 {
                    origin.x = origin.x + size.width + self.crossAxisSpacing
                    origin.y = 0
                }
                
                let view = self.views[i]
                
                if view.superview != self {
                    if view.superview != nil {
                        view.removeFromSuperview()
                    }
                    self.addSubview(view)
                }
                
                var rect: CGRect = .zero
                rect.origin = origin
                rect.size = size
                view.frame = rect
                
                origin.y = rect.maxY + self.mainAxisSpacing
            }
            
            self.innerContentSize.width = self.views.last?.frame.maxX ?? 0
        }
    }
    

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview != nil && self.isNeedRelayout {
            self.relayoutViews()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return self.innerContentSize
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return self.innerContentSize
    }
    
    override func sizeToFit() {
        self.relayoutViews()
        super.sizeToFit()
    }
    
}
