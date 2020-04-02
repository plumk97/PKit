//
//  PLArrangeView.swift
//  PLKit
//
//  Created by iOS on 2020/4/2.
//  Copyright © 2020 iOS. All rights reserved.
//

import UIKit

class PLArrangeView: UIView {
    enum Direction {
        case horizontal
        case vertical
    }
    var direction = Direction.horizontal {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    enum Alignment {
        case left, right // vertical
        case center
        case top, bottom // horizontal
    }
    var alignment = Alignment.center {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    var spacing: CGFloat = 10 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    private(set) var views = [UIView]()
    private var innerContentSize = CGSize.zero
    
    convenience init(views: [UIView]) {
        self.init(frame: .zero)
        self.views = views
        self.loadViews()
    }
    
    
    private func loadViews() {
        for view in self.views {
            self.addSubview(view)
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.direction == .horizontal {
            
            var maxHeight: CGFloat = 0
            for view in self.views {
                if view.frame.size.equalTo(.zero) {
                    view.sizeToFit()
                }
                maxHeight = max(view.frame.height, maxHeight)
            }
            
            var left: CGFloat = 0
            for view in self.views {
                if self.alignment == .top {
                    view.frame.origin = .init(x: left, y: 0)
                } else if self.alignment == .bottom {
                    view.frame.origin = .init(x: left, y: maxHeight - view.frame.height)
                } else {
                    view.frame.origin = .init(x: left, y: (maxHeight - view.frame.height) / 2)
                }
                left = view.frame.maxX + self.spacing
            }
            
            self.innerContentSize = .init(width: left - self.spacing, height: maxHeight)
            
        } else {
            
            var maxWidth: CGFloat = 0
            for view in self.views {
                if view.frame.size.equalTo(.zero) {
                    view.sizeToFit()
                }
                maxWidth = max(view.frame.width, maxWidth)
            }
            
            var top: CGFloat = 0
            for view in self.views {
                if self.alignment == .left {
                    view.frame.origin = .init(x: 0, y: top)
                } else if self.alignment == .left {
                    view.frame.origin = .init(x: maxWidth - view.frame.width, y: top)
                } else {
                    view.frame.origin = .init(x: (maxWidth - view.frame.width) / 2, y: top)
                }
                top = view.frame.maxY + self.spacing
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
}
