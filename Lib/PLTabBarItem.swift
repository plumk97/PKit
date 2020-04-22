//
//  PLTabBarItem.swift
//  PLKit
//
//  Created by iOS on 2019/8/7.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class PLTabBarItem: UIView {
    
    private(set) var isSelected: Bool = false
    
    let style = Style()
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
        self.imageView.animationRepeatCount = 1
        self.addSubview(self.imageView)
        
        self.badgeView = PLBadgeView()
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
    
    func setSelected(_ selected: Bool) {
        self.isSelected = selected
        self.reloadData()
    }

    override func layoutSubviews() {
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

// MARK: - Class PLTabBarItem.Style
extension PLTabBarItem {
    class Style: NSObject {
        
        fileprivate weak var item: PLTabBarItem?
        
        // -- image
        var image: UIImage? {
            didSet {
                self.item?.reloadData()
                self.item?.setNeedsLayout()
            }
        }
        
        var selectedImage: UIImage? { didSet { self.item?.reloadData() }}
        
        var selectedImages: [UIImage]? { didSet { self.item?.reloadData() }}
        
        // -- title
        var title: String? {
            didSet {
                self.item?.reloadData()
                self.item?.setNeedsLayout()
            }
        }
        
        var color = UIColor.init(red: 0.6, green: 0.6, blue: 0.6, alpha: 1) { didSet { self.item?.reloadData() }}
        
        var selectedColor = UIColor.init(red: 0.13, green: 0.13, blue: 0.13, alpha: 1) { didSet { self.item?.reloadData() }}
        
        // -- offset
        var spacing: CGFloat = 4 { didSet { self.item?.setNeedsLayout() }}
        var titleOffset: CGPoint = .zero { didSet { self.item?.setNeedsLayout() }}
        var imageOffset: CGPoint = .zero { didSet { self.item?.setNeedsLayout() }}
        var badgeOffset: CGPoint = .zero { didSet { self.item?.setNeedsLayout() }}
    }
}

// MARK: - Extension UIViewController.PL.tabBarItem
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
