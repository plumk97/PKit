//
//  PLKit.swift
//  PLKit
//
//  Created by Plumk on 2019/4/23.
//  Copyright © 2019 Plumk. All rights reserved.
//

import UIKit

struct PL<Base> {
    let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
}

extension NSObjectProtocol where Self: UIView {
    
    var pl: PL<Self> {
        return PL(self)
    }
}

extension NSObjectProtocol where Self: CALayer {
    
    var pl: PL<Self> {
        return PL(self)
    }
}

extension NSObjectProtocol where Self: UIViewController {
    
    var pl: PL<Self> {
        return PL(self)
    }
}


struct PLKit {
    
    struct Color {
        
        /// 创建过渡颜色
        /// - Parameters:
        ///   - fromColor: 起始颜色
        ///   - toColor: 最终颜色
        ///   - progress: 进度
        static func makeTransitionColor(from fromColor: UIColor, to toColor: UIColor, progress: CGFloat) -> UIColor {
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            
            var r1: CGFloat = 0
            var g1: CGFloat = 0
            var b1: CGFloat = 0
            var a1: CGFloat = 0
            
            
            fromColor.getRed(&r, green: &g, blue: &b, alpha: &a)
            toColor.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
            
            
            let r2 = r + (r1 - r) * progress
            let g2 = g + (g1 - g) * progress
            let b2 = b + (b1 - b) * progress
            let a2 = a + (a1 - a) * progress
            
            return .init(red: r2, green: g2, blue: b2, alpha: a2)
        }
    }
}


extension UIEdgeInsets {
    func equalTo(_ insets: UIEdgeInsets) -> Bool {
        return self.top == insets.top && self.left == insets.left && self.right == insets.right && self.bottom == insets.bottom
    }
}


class PLConstraint: NSLayoutConstraint {
    
    static func make(item view1: Any?, attribute attr1: NSLayoutConstraint.Attribute, relatedBy relation: NSLayoutConstraint.Relation, toItem view2: Any?, attribute attr2: NSLayoutConstraint.Attribute, multiplier: CGFloat, constant c: CGFloat, priority: UILayoutPriority = .required) -> PLConstraint {
        let constraint = PLConstraint.init(item: view1!, attribute: attr1, relatedBy: relation, toItem: view2, attribute: attr2, multiplier: multiplier, constant: c)
        constraint.priority = priority
        
        return constraint
    }
}

