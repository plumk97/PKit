//
//  PKUINavigationContainerBar.swift
//  PKit
//
//  Created by Plumk on 2021/11/4.
//

import UIKit


open class PKUINavigationContainerBar: UIView {
    
    /// 状态栏高度
    open var statusBarHeight: CGFloat = 20
    
    /// 系统导航栏
    open private(set) var systemNavigationBar: UINavigationBar!
    
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
        
        self.systemNavigationBar = UINavigationBar()
        self.systemNavigationBar.isTranslucent
        self.systemNavigationBar.setBackgroundImage(UIImage(), for: .default)
        self.addSubview(self.systemNavigationBar)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let navigationBarHeight = SystemNavigationBarHeight()
        self.systemNavigationBar.frame = .init(x: 0, y: self.frame.height - navigationBarHeight + self.navigationBarOffsetY, width: self.frame.width, height: navigationBarHeight)
    }
}


/// 系统导航栏高度
func SystemNavigationBarHeight() -> CGFloat {
    
    if UIDevice.current.model == "iPad" {
        return 50
    }
    
    if UIApplication.shared.statusBarOrientation.isPortrait {
        /// 竖屏高度
        return 44
    }

    /// 屏幕宽度大于400 横屏导航栏高度为44
    if UIScreen.main.nativeBounds.width / UIScreen.main.nativeScale > 400 {
        return 44
    } else {
        return 32
    }
}
