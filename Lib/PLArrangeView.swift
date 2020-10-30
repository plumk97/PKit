//
//  PLArrangeView.swift
//  PLKit
//
//  Created by Plumk on 2020/4/2.
//  Copyright © 2020 iOS. All rights reserved.
//

import UIKit

class PLArrangeView: UIView {
    
    // 布局方向
    var direction = Direction.horizontal { didSet { self.setNeedsLayout() } }
    
    // 对齐方式
    var alignment = Alignment.center { didSet { self.setNeedsLayout() } }
    
    // 间距
    var spacing: CGFloat = 10 { didSet { self.setNeedsLayout() } }
    
    // 分割线
    var divider = Divider() { didSet { self.setNeedsLayout() } }
    
    // 是否显示分割线
    var showDivider = false { didSet { self.setNeedsLayout() } }
    
    // 加载的view
    var views: [UIView]? { didSet { self.reload(oldViews: oldValue) }}
    
    // 指定某条分割线是否显示
    private var specificDividerShows = [Int: Bool]()
    
    // 分割线
    private var dividerViews = [UIView]()
    
    // 显示所需的大小
    private var innerContentSize = CGSize.zero
    

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(views: [UIView]? = nil, showDivider: Bool = false) {
        super.init(frame: .zero)
        
        self.views = views
        self.showDivider = showDivider
        self.loadViews()
        self.clipsToBounds = true
    }
    
    /// 加载view 和 分割线
    private func loadViews() {
        
        guard let views = self.views else {
            return
        }
        
        for _ in 0 ..< views.count - 1 {
            let d = UIView()
            d.isHidden = true
            self.addSubview(d)
            self.dividerViews.append(d)
        }
        
        for view in views {
            self.addSubview(view)
        }
        
        self.setNeedsLayout()
    }
    
    
    /// 重新加载 - 清理之前的
    /// - Parameter oldViews:
    private func reload(oldViews: [UIView]?) {
        
        self.specificDividerShows.removeAll()
        
        self.dividerViews.forEach({ $0.removeFromSuperview() })
        self.dividerViews.removeAll()
        
        oldViews?.forEach({ $0.removeFromSuperview() })
        
        self.loadViews()
    }
    
    /// 提升某个view到最前面显示
    /// - Parameter idx:
    func bringSubviewToFront(_ idx: Int) {
        guard let views = self.views else {
            return
        }
        
        guard idx < views.count && idx >= 0 else {
            return
        }
        
        let view = views[idx]
        self.bringSubviewToFront(view)
    }
    
    
    /// 指定某条分割线是否显示
    /// - Parameters:
    ///   - isShow:
    ///   - index:
    func showDivider(_ isShow: Bool, index: Int) {
        guard let views = self.views else {
            return
        }
        
        guard index < views.count && index >= 0 else {
            return
        }
        
        self.specificDividerShows[index] = isShow
        self.setNeedsLayout()
    }
    
    
    // --
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let views = self.views else {
            
            self.innerContentSize = .zero
            self.invalidateIntrinsicContentSize()
            return
        }
        
        if self.direction == .horizontal {
            
            var maxHeight: CGFloat = 0
            for view in views {
                if view.frame.size.equalTo(.zero) {
                    view.sizeToFit()
                }
                maxHeight = max(view.frame.height, maxHeight)
            }
            
            var left: CGFloat = 0
            for (idx, view) in views.enumerated() {
                if self.alignment == .top {
                    view.frame.origin = .init(x: left, y: 0)
                } else if self.alignment == .bottom {
                    view.frame.origin = .init(x: left, y: maxHeight - view.frame.height)
                } else {
                    view.frame.origin = .init(x: left, y: (maxHeight - view.frame.height) / 2)
                }
                
                left = view.frame.maxX + self.spacing
                
                // layout divider
                if idx < self.dividerViews.count {
                   
                    let d = self.dividerViews[idx]
                    let specificShow = self.specificDividerShows[idx]
                    if specificShow ?? self.showDivider {
                        d.backgroundColor = divider.color
                        d.isHidden = false
                        d.frame = .init(x: left, y: divider.truncation, width: divider.width, height: maxHeight - divider.truncation * 2)
                        
                        left = d.frame.maxX + self.spacing
                    } else {
                        d.isHidden = true
                    }
                }
            }
            
            self.innerContentSize = .init(width: left - self.spacing, height: maxHeight)
            
        } else {
            
            var maxWidth: CGFloat = 0
            for view in views {
                if view.frame.size.equalTo(.zero) {
                    view.sizeToFit()
                }
                maxWidth = max(view.frame.width, maxWidth)
            }
            
            var top: CGFloat = 0
            for (idx, view) in views.enumerated() {
                if self.alignment == .left {
                    view.frame.origin = .init(x: 0, y: top)
                } else if self.alignment == .left {
                    view.frame.origin = .init(x: maxWidth - view.frame.width, y: top)
                } else {
                    view.frame.origin = .init(x: (maxWidth - view.frame.width) / 2, y: top)
                }
                top = view.frame.maxY + self.spacing
                
                // layout divider
                if idx < self.dividerViews.count {
                   
                    let d = self.dividerViews[idx]
                    let specificShow = self.specificDividerShows[idx]
                    
                    if specificShow ?? self.showDivider {
                        d.backgroundColor = divider.color
                        d.isHidden = false
                        d.frame = .init(x: divider.truncation, y: top, width: maxWidth - divider.truncation * 2, height: divider.width)
                        
                        top = d.frame.maxY + self.spacing
                    } else {
                        d.isHidden = true
                    }
                }
            }
            
            self.innerContentSize = .init(width: maxWidth, height: top - self.spacing)
        }
        
        self.invalidateIntrinsicContentSize()
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


extension PLArrangeView {
    enum Direction {
        case horizontal
        case vertical
    }
    
    enum Alignment {
        case left, right // vertical
        case center
        case top, bottom // horizontal
    }
    
    
    struct Divider {
        var color: UIColor = .init(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
        var width: CGFloat = 0.5
        var truncation: CGFloat = 0
    }
    
}
