//
//  PLNavigationContainerViewController.swift
//  PKit
//
//  Created by Plumk on 2021/11/4.
//

import UIKit

open class PLNavigationContainerViewController: UIViewController {
    
    /// 当前容器是否已经 Push 进 PLNavigationController
    var isPushed: Bool = false
    
    /// 解包使用的NavigationController
    open private(set) var unwarpNavigationController: PLUnwrapNavigationController!
    
    /// 实际显示内容ViewController
    open private(set) var content: UIViewController!
    
    /// 导航栏是否隐藏
    open private(set) var isNavigationBarHidden: Bool = false
    
    /// 包裹系统导航栏
    open private(set) var containerBar: PLNavigationContainerBar!
    
    /// 当前页导航配置
    open private(set) var config = PLNavigationConfig()
    
    public init(content: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        
        self.content = content
        self.commInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commInit()
    }
    
    fileprivate func commInit() {
        
        self.containerBar = PLNavigationContainerBar()
        
        guard self.content != nil else {
            return
        }
        
        self.unwarpNavigationController = PLUnwrapNavigationController.init(rootViewController: self.content)
        self.addChild(self.unwarpNavigationController)
    }
    
    deinit {
        // 需要手动释放 不会自动释放 系统的没这个问题 不知什么原因
        self.content.navigationItem.leftBarButtonItems = nil
        self.content.navigationItem.rightBarButtonItems = nil
        self.content.navigationItem.backBarButtonItem = nil
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        guard self.content != nil else {
            return
        }
        
        
        self.config.didChangeBackItemCallback = {[unowned self] in
            self.updateBackItemWithConfig()
        }
        self.updateBackItemWithConfig()
        

        // -- 先调整frame
        self.view.layoutIfNeeded()
        self.view.addSubview(self.unwarpNavigationController.view)
        
        self.containerBar.navigationBar.pushItem(self.content.navigationItem, animated: false)
        self.view.addSubview(self.containerBar)
    }
    
    /// 更新返回按钮
    open func updateBackItemWithConfig() {
        // -- 当前不是第一个才加入返回按钮
        if self != self.navigationController?.viewControllers.first {

            
            // -- back item
            if let item = self.config.backItem {
                self.content.navigationItem.leftBarButtonItem = item
            } else {
                
                let backButton = BackItemButton(type: .system)

                if let image = self.config.backItemImage {
                    backButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
                    backButton.frame.size = .init(width: image.size.width + 19, height: 44)
                } else {
                    backButton.setTitle("Back", for: .normal)
                    backButton.frame.size = .init(width: backButton.sizeThatFits(.zero).width, height: 44)
                }

                backButton.addTarget(self, action: #selector(backBarButtonItemClick), for: .touchUpInside)

                // 直接使用 .init(image: ) 在 iOS11以上 与 iOS11以下 表现不一样
                self.content.navigationItem.leftBarButtonItem = .init(customView: backButton)
            }
        }
    }
    
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var navBarFrame = CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: 0)
        
        // 获取当前状态栏高度
        var statusBarHeight: CGFloat = 0
        if self.view.frame.width < self.view.frame.height {
            // 只判断竖屏 横屏都是0
            if #available(iOS 11, *) {
                if self.view.safeAreaInsets.bottom > 0 {
                    // 全面屏不会出现状态栏上移的问题 直接取safeAreaInsets.top
                    statusBarHeight = self.view.safeAreaInsets.top
                } else {
                    // 非全面屏固定20
                    statusBarHeight = 20
                }
            } else {
                // iOS11以下固定20
                statusBarHeight = 20
            }
        }
        navBarFrame.size.height = statusBarHeight + PLNavigationContainerBar.navigationBarHeight
        
        // -- 判断隐藏状态
        if self.isNavigationBarHidden {
            navBarFrame.origin.y = -navBarFrame.height
        } else {
            navBarFrame.origin.y = 0
        }
        
        self.containerBar.statusBarHeight = statusBarHeight
        self.containerBar.frame = navBarFrame
        self.unwarpNavigationController.view.frame = self.view.bounds
    }
    
    @objc fileprivate func backBarButtonItemClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    open func setNavigationBarHidden(_ isHidden: Bool, animated: Bool) {
        guard self.isNavigationBarHidden != isHidden else {
            return
        }
        self.isNavigationBarHidden = isHidden
        if animated {
            var frame = self.containerBar.frame
            frame.origin.y = isHidden ? -frame.size.height : 0
            UIView.animate(withDuration: 0.25) {
                self.containerBar.frame = frame
                
            }
        } else {
            self.containerBar.isHidden = isHidden
        }
    }
    
    // MARK: - Child
    open override var childForStatusBarStyle: UIViewController? {
        return self.unwarpNavigationController
    }
    
    open override var childForStatusBarHidden: UIViewController? {
        return self.unwarpNavigationController
    }
    
    open override var childForHomeIndicatorAutoHidden: UIViewController? {
        return self.unwarpNavigationController
    }
    
    open override var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        return self.unwarpNavigationController
    }
    
    open override var prefersStatusBarHidden: Bool {
        return self.unwarpNavigationController?.prefersStatusBarHidden ?? false
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.unwarpNavigationController?.preferredStatusBarStyle ?? .default
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return self.unwarpNavigationController?.preferredStatusBarUpdateAnimation ?? .fade
    }
    
    open override var shouldAutorotate: Bool {
        return self.unwarpNavigationController?.shouldAutorotate ?? false
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return self.unwarpNavigationController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.unwarpNavigationController?.supportedInterfaceOrientations ?? .portrait
    }
    
}

// MARK: - UIGestureRecognizerDelegate
extension PLNavigationContainerViewController: UIGestureRecognizerDelegate {
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer else {
            return true
        }
        return !self.config.isDisablePopGestureRecognizer
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer
    }
}

// MARK: - BackItemButton
extension PLNavigationContainerViewController {
    
    open class BackItemButton: UIButton {
        // 避免返回按钮看起来不靠左
        open override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
            var rect = super.imageRect(forContentRect: contentRect)
            rect.origin.x = 0
            return rect
        }
    }
}

// MARK: - Extension UIViewController.PL.PLNavigationContainerViewController
extension PL where Base: UIViewController {
    public var navigationConfig: PLNavigationConfig? {
        
        if let container = self.base.navigationController?.parent as? PLNavigationContainerViewController {
            return container.config
        }
        
        if let container = self.base.parent as? PLNavigationContainerViewController {
            return container.config
        }
        
        if let container = self.base as? PLNavigationContainerViewController {
            return container.config
        }
        
        return nil
    }
    
    public var containerContentViewController: UIViewController {
        if let container = self.base as? PLNavigationContainerViewController {
            return container.content
        }
        return self.base
    }
}
