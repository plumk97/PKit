//
//  PLTabBar.swift
//  PLKit
//
//  Created by iOS on 2019/8/7.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

@objc protocol PLTabBarDelegate: NSObjectProtocol {
    
    /// 将要选中某个index 返回 false 则不选中
    /// - Parameters:
    ///   - tabBar:
    ///   - index:
    @objc optional func tabBar(_ tabBar: PLTabBar, willSelect index: Int) -> Bool
    
    /// 选中某个index
    /// - Parameters:
    ///   - tabBar:
    ///   - index:
    @objc optional func tabBar(_ tabBar: PLTabBar, didSelect index: Int)
    
    /// 双击某个index
    /// - Parameters:
    ///   - tabBar:
    ///   - index:
    @objc optional func tabBar(_ tabBar: PLTabBar, didDoubleTap index: Int)
}

class PLTabBar: UIView {
    
    weak var delegate: PLTabBarDelegate?
    
    /// 内容高度 去掉safe边距
    var contentHeight: CGFloat = 0 { didSet { self.setNeedsLayout() }}
    
    ///
    var items: [PLTabBarItem]? { didSet { self.reloadItems(oldValue) }}
    
    private(set) var selectedIndex = 0
    
    /// 当前选中item
    var selectedItem: PLTabBarItem? {
        guard let items = items else {
            return nil
        }
        if selectedIndex >= 0 && selectedIndex < items.count {
            return items[selectedIndex]
        }
        return nil
    }
    
    
    private(set) var divider: UIView!
    private var contentView: UIView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commInit()
    }
    
    private func commInit() {
        self.backgroundColor = .white
        
        self.contentView = UIView()
        self.addSubview(contentView)
        
        // 分割线
        self.divider = UIView()
        self.divider.backgroundColor = .init(red: 0.898, green: 0.898, blue: 0.898, alpha: 1)
        self.addSubview(self.divider)
        
        // -- 双击手势
        let doubleTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(doubleTapGestureHandle(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.delaysTouchesBegan = false
        doubleTapGesture.delaysTouchesEnded = false
        self.contentView.addGestureRecognizer(doubleTapGesture)
    }
    
    /// 双击手势
    /// - Parameter sender:
    @objc func doubleTapGestureHandle(_ sender: UITapGestureRecognizer) {
        
        let count = self.items?.count ?? 0
        guard count > 0 else {
            return
        }
        
        let point = sender.location(in: self)
        let width = ceil(contentView.frame.width / CGFloat(count))
        let idx = Int(point.x / width)
        self.delegate?.tabBar?(self, didDoubleTap: idx)
    }
    
    
    /// 重新加载items
    /// - Parameter oldItems:
    private func reloadItems(_ oldItems: [PLTabBarItem]?) {
        oldItems?.forEach({ $0.removeFromSuperview() })
        
        guard let items = self.items else {
            return
        }
        items.forEach({[unowned self] in
            self.contentView.addSubview($0)
        })
        
        self.setSelectedIndex(self.selectedIndex, animation: false)
        self.setNeedsLayout()
    }
    
    
    /// 设置选中index
    /// - Parameters:
    ///   - index:
    ///   - animation: 是否使用动画 -- 简单的图片帧动画
    func setSelectedIndex(_ index: Int, animation: Bool) {
        self.selectedItem?.setSelected(false)
        self.selectedIndex = index
        self.selectedItem?.setSelected(true)
        if animation {
            self.selectedItem?.imageView.startAnimating()
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.divider.frame = .init(x: 0, y: 0, width: bounds.width, height: 0.5)
        
        
        // -- 布局item
        let height = contentHeight > 0 ? contentHeight : bounds.height
        self.contentView.frame = .init(x: 0, y: 0, width: bounds.width, height: height)
        
        guard let items = items else {
            return
        }
        
        let width = self.contentView.bounds.width / CGFloat(items.count)
        for (idx, item) in items.enumerated() {
            item.frame = .init(x: CGFloat(idx) * width, y: 0, width: width, height: height)
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        /// 判断点击了哪一个item
        
        guard let point = touches.first?.location(in: self.contentView) else {
            return
        }
        
        guard let items = self.items else {
            return
        }
        
        for (index, item) in items.enumerated() {
            if item.frame.contains(point) {
                
                if self.delegate?.tabBar?(self, willSelect: index) ?? true {
                    self.setSelectedIndex(index, animation: true)
                    self.delegate?.tabBar?(self, didSelect: index)
                }
                break
            }
        }
        
    }
}
