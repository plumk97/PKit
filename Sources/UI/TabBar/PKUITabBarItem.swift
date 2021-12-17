//
//  PKUITabBarItem.swift
//  PKit
//
//  Created by Plumk on 2019/8/7.
//  Copyright © 2019 Plumk. All rights reserved.
//

import UIKit

open class PKUITabBarItem: UIView {
    
    private(set) var isSelected: Bool = false
    
    public let style = Style()
    open private(set) var titleLabel: UILabel!
    open private(set) var imageView: UIImageView!
    open private(set) var badgeView: PKUIBadgeView!
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        commInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commInit()
    }
    
    private func commInit() {
        self.style.item = self
        self.titleLabel = UILabel()
        self.titleLabel.font = .boldSystemFont(ofSize: 11)
        self.addSubview(self.titleLabel)
        
        self.imageView = UIImageView()
        self.imageView.animationRepeatCount = 1
        self.addSubview(self.imageView)
        
        self.badgeView = PKUIBadgeView()
        self.addSubview(self.badgeView)
    }
    
    fileprivate func reloadData() {
        
        self.titleLabel.text = self.style.title
        if self.isSelected {
            self.titleLabel.textColor = self.style.selectedColor
            if let images = self.style.selectedImages {
                self.imageView.image = images.last
                self.imageView.animationImages = images
            } else if let image = self.style.selectedImage {
                self.imageView.image = image
            }
            
        } else {
            self.titleLabel.textColor = self.style.color
            self.imageView.image = self.style.image
            self.imageView.animationImages = nil
        }
    }
    
    open func setSelected(_ selected: Bool) {
        self.isSelected = selected
        self.reloadData()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        
        
        self.imageView.sizeToFit()
        self.titleLabel.sizeToFit()
        
        let sumHeight = self.imageView.bounds.height + self.titleLabel.bounds.height + self.style.spacing
        
        let top = (bounds.height - sumHeight) / 2
        self.imageView.frame.origin = .init(x: (bounds.width - self.imageView.frame.width) / 2 + self.style.imageOffset.x,
                                            y: top + self.style.imageOffset.x)
        
        self.titleLabel.frame.origin = .init(x: (bounds.width - self.titleLabel.frame.width) / 2 + self.style.titleOffset.x,
                                             y: self.imageView.frame.maxY + self.style.spacing + self.style.titleOffset.y)

        
        self.badgeView.frame.origin = .init(x: bounds.width / 2 + 6 + self.style.badgeOffset.x,
                                            y: 3 + self.style.badgeOffset.y)
    }
}

// MARK: - Class PKUITabBarItem.Style
extension PKUITabBarItem {
    open class Style: NSObject {
        
        fileprivate weak var item: PKUITabBarItem?
        
        // -- image
        open var image: UIImage? {
            didSet {
                self.item?.reloadData()
                self.item?.setNeedsLayout()
            }
        }
        
        open var selectedImage: UIImage? { didSet { self.item?.reloadData() }}
        
        open var selectedImages: [UIImage]? { didSet { self.item?.reloadData() }}
        
        // -- title
        open var title: String? {
            didSet {
                self.item?.reloadData()
                self.item?.setNeedsLayout()
            }
        }
        
        open var color = UIColor.init(red: 0.6, green: 0.6, blue: 0.6, alpha: 1) { didSet { self.item?.reloadData() }}
        
        open var selectedColor = UIColor.init(red: 0.13, green: 0.13, blue: 0.13, alpha: 1) { didSet { self.item?.reloadData() }}
        
        // -- offset
        open var spacing: CGFloat = 4 { didSet { self.item?.setNeedsLayout() }}
        open var titleOffset: CGPoint = .zero { didSet { self.item?.setNeedsLayout() }}
        open var imageOffset: CGPoint = .zero { didSet { self.item?.setNeedsLayout() }}
        open var badgeOffset: CGPoint = .zero { didSet { self.item?.setNeedsLayout() }}
    }
}

// MARK: - Extension UIViewController.PL.tabBarItem
fileprivate var kPKUITabBarItem = "PKUITabBarItem"
extension PK where Base: UIViewController {
    public var tabBarItem: PKUITabBarItem {
        var obj = objc_getAssociatedObject(self.base, &kPKUITabBarItem) as? PKUITabBarItem
        if obj == nil {
            obj = PKUITabBarItem()
            objc_setAssociatedObject(self.base, &kPKUITabBarItem, obj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return obj!
    }
}
