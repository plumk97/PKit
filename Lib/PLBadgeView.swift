//
//  PLBadgeView.swift
//  PLKit
//
//  Created by 李铁柱 on 2019/6/9.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class PLBadgeView: UIImageView {
    
    var string: String? {
        didSet {
            label.text = string
            self.sizeToFit()
        }
    }
    private var label: UILabel!
    convenience init() {
        self.init(frame: .zero)
        self.commInit()
    }
    
    private func commInit() {
        self.backgroundColor = .init(red: 1, green: 0.231373, blue: 0.188235, alpha: 1)
        
        self.label = UILabel()
        self.label.font = UIFont.init(name: ".SFUIText", size: 13)
        self.label.textAlignment = .center
        self.label.textColor = .white
        self.addSubview(self.label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.label.frame = self.bounds.insetBy(dx: 5, dy: 1)
        self.layer.cornerRadius = self.bounds.height / 2
    }
    
    override var intrinsicContentSize: CGSize {
        return self.sizeThatFits(.zero)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = self.label.sizeThatFits(.zero)
        size.width += 10
        size.height += 2
        return .init(width: ceil(size.width), height: ceil(size.height))
    }
    
}
