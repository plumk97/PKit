//
//  PKUIBadgeView.swift
//  PKit
//
//  Created by Plumk on 2019/6/9.
//  Copyright © 2019 Plumk. All rights reserved.
//

import UIKit

open class PKUIBadgeView: UIImageView {
    
    open var string: String? {
        didSet {
            self.isHidden = (string?.count ?? 0) <= 0
            label.text = string
            self.invalidateIntrinsicContentSize()
            self.sizeToFit()
        }
    }
    open var boundsInsets: CGSize = .init(width: 10, height: 2)
    open private(set) var label: UILabel!
    public convenience init() {
        self.init(frame: .zero)
        self.commInit()
    }
    
    private func commInit() {
        self.backgroundColor = .init(red: 1, green: 0.231373, blue: 0.188235, alpha: 1)
        self.layer.masksToBounds = true
        self.label = UILabel()
        if #available(iOS 13.0, *) {
            self.label.font = UIFont.systemFont(ofSize: 13)
        } else {
            self.label.font = UIFont.init(name: ".SFUIText", size: 13)
        }
        self.label.textAlignment = .center
        self.label.textColor = .white
        self.addSubview(self.label)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        var size = self.label.sizeThatFits(.zero)
        size.width += 1
        self.label.frame = .init(x: (self.bounds.width - size.width) / 2,
                                 y: (self.bounds.height - size.height) / 2,
                                 width: size.width,
                                 height: size.height)
        
        self.layer.cornerRadius = self.bounds.height / 2
    }
    
    open override var intrinsicContentSize: CGSize {
        return self.sizeThatFits(.zero)
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = self.label.sizeThatFits(.zero)
        size.width += self.boundsInsets.width
        size.height += self.boundsInsets.height
        
        size.width = max(size.width, size.height)
        return .init(width: ceil(size.width), height: ceil(size.height))
    }
    
}
