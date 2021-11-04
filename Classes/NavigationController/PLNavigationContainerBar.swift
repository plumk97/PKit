//
//  PLNavigationContainerBar.swift
//  PKit
//
//  Created by Plumk on 2021/11/4.
//

import UIKit


open class PLNavigationContainerBar: UIView {
    
    /// 导航栏高度
    public static var navigationBarHeight: CGFloat {
        
        if #available(iOS 11, *) {
            let insets = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
            if insets.bottom > 0 {
                /// 全面屏导航栏高度固定44
                return 44
            }
        }
        
        if UIApplication.shared.statusBarOrientation.isPortrait {
            /// 竖屏高度
            return 44
        }
        
        /// 横屏高度
        return 32
    }
    
    
    /// 状态栏高度
    open var statusBarHeight: CGFloat = 20
    
    /// 系统导航栏
    open private(set) var navigationBar: UINavigationBar!
    
    /// 系统导航栏Y偏移
    open var navigationBarOffsetY: CGFloat = 0
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commInit()
    }
    
    fileprivate func commInit() {
        
        self.backgroundColor = UIColor.white
        
        self.navigationBar = UINavigationBar()
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.addSubview(self.navigationBar)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentHeight = self.frame.height - self.statusBarHeight
        let navigationBarHeight = type(of: self).navigationBarHeight
        
        /// 去掉状态栏高度然后居中显示
        let middleY = (contentHeight - navigationBarHeight) / 2
        self.navigationBar.frame = .init(x: 0, y: self.statusBarHeight + middleY + self.navigationBarOffsetY, width: self.frame.width, height: navigationBarHeight)
    }
}
