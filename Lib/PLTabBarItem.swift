//
//  PLTabBarItem.swift
//  PLKit
//
//  Created by iOS on 2019/8/7.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class PLTabBarItem: UIView {
    
    var isSelected: Bool = false { didSet{ update() } }
    
    private(set) var style = Style()
    private(set) var titleLabel: UILabel!
    private(set) var imageView: UIImageView!
    private(set) var badgeView: PLBadgeView!
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        commInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commInit()
    }
    
    private func commInit() {
        self.style.item = self
        self.titleLabel = UILabel()
        self.titleLabel.font = .boldSystemFont(ofSize: 11)
        self.addSubview(self.titleLabel)
        
        self.imageView = UIImageView()
        self.addSubview(self.imageView)
        
        self.badgeView = PLBadgeView()
        self.addSubview(self.badgeView)
    }
    
    fileprivate func update() {
        self.titleLabel.text = self.style.title
        self.titleLabel.textColor = self.isSelected ? self.style.selectedColor : self.style.color
        self.imageView.image = self.isSelected ? self.style.selectedImage : self.style.image
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView.sizeToFit()
        self.imageView.center.x = bounds.width / 2 + self.style.imageOffset.x
        self.imageView.center.y = bounds.height / 2 - 8 + self.style.imageOffset.y
        
        self.titleLabel.sizeToFit()
        self.titleLabel.center.x = bounds.width / 2 + self.style.titleOffset.x
        self.titleLabel.frame.origin.y = bounds.height - self.titleLabel.bounds.height - 5 + self.style.titleOffset.y
        
        self.badgeView.frame.origin = .init(x: bounds.width / 2 + 6 + self.style.badgeOffset.x,
                                            y: 3 + self.style.badgeOffset.y)
    }
}

extension PLTabBarItem {
    class Style: NSObject {
        
        fileprivate weak var item: PLTabBarItem?
        
        // -- image
        var image: UIImage? {
            didSet {
                self.item?.update()
                self.item?.setNeedsLayout()
            }
        }
        
        var selectedImage: UIImage? {
            didSet {
                self.item?.update()
                self.item?.setNeedsLayout()
            }
        }
        
        
        // -- title
        var title: String? {
            didSet {
                self.item?.update()
                self.item?.setNeedsLayout()
            }
        }
        
        var color = UIColor.init(red: 0.6, green: 0.6, blue: 0.6, alpha: 1) {
            didSet {
                self.item?.update()
            }
        }
        
        var selectedColor = UIColor.init(red: 0.13, green: 0.13, blue: 0.13, alpha: 1) {
            didSet {
                self.item?.update()
            }
        }
        
        // -- offset
        var titleOffset: CGPoint = .zero
        var imageOffset: CGPoint = .zero
        var badgeOffset: CGPoint = .zero
    }
}

fileprivate var kPLTabBarItem = "PLTabBarItem"
extension PL where Base: UIViewController {
    var tabBarItem: PLTabBarItem {
        var obj = objc_getAssociatedObject(self.base, &kPLTabBarItem) as? PLTabBarItem
        if obj == nil {
            obj = PLTabBarItem()
            objc_setAssociatedObject(self.base, &kPLTabBarItem, obj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return obj!
    }
}
