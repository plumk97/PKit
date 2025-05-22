//
//  PKUINavigationContainerViewController.swift
//  PKit
//
//  Created by Plumk on 2021/11/4.
//

import UIKit

open class PKUINavigationContainerViewController: UIViewController {
    
    /// 当前容器是否已经 Push 进 PKUINavigationController
    var isPushed: Bool = false
    
    /// 解包使用的NavigationController
    open private(set) var unwarpNavigationController: PKUIUnwrapNavigationController!
    
    /// 实际显示内容ViewController
    open private(set) var content: UIViewController!
    
    /// 导航栏是否隐藏
    open private(set) var isNavigationBarHidden: Bool = false
    
    /// 包裹系统导航栏
    open private(set) var containerBar: PKUINavigationContainerBar!
    
    /// 当前页导航配置
    open private(set) var config = PKUINavigationConfig()
    
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
        
        self.containerBar = PKUINavigationContainerBar()
        
        guard self.content != nil else {
            return
        }
        
        self.unwarpNavigationController = PKUIUnwrapNavigationController.init(rootViewController: self.content)
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
        
        
        /// - callback
        self.config.didChangeBackItemCallback = {[unowned self] in
            self.updateBackItemWithConfig()
        }
        
        self.config.didChangeBarHeightCallback = {[unowned self] in
            self.view.setNeedsLayout()
        }
        
        self.updateBackItemWithConfig()
        

        // -- 先调整frame
        self.view.layoutIfNeeded()
        self.view.addSubview(self.unwarpNavigationController.view)
        
        self.containerBar.systemNavigationBar.pushItem(self.content.navigationItem, animated: false)
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
                    backButton.setImage(image, for: .normal)
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
        
        if UIDevice.current.model == "iPad" {
            
            if !self.prefersStatusBarHidden {
                
                if #available(iOS 11, *) {
                    statusBarHeight = PKUIWindowGetter.safeAreaInsets.top
                } else {
                    statusBarHeight = 20
                }
            }
            
        } else {
            
            // iPhone 只判断竖屏 横屏没有状态栏
            if UIApplication.shared.statusBarOrientation.isPortrait {
                let safeAreaInsets = PKUIWindowGetter.safeAreaInsets
                if #available(iOS 11, *) {
                    if safeAreaInsets.bottom > 0 || !self.prefersStatusBarHidden {
                        statusBarHeight = PKUIWindowGetter.safeAreaInsets.top
                    }
                    
                } else if !self.prefersStatusBarHidden {
                    statusBarHeight = 20
                }
            }
            
        }
        
        
        if UIApplication.shared.statusBarOrientation.isPortrait {
            navBarFrame.size.height = statusBarHeight + self.config.navigationBarHeight
        } else {
            navBarFrame.size.height = statusBarHeight + self.config.landscapeNavigationBarHeight
        }
        
        // -- 判断隐藏状态
        if self.isNavigationBarHidden {
            navBarFrame.origin.y = -navBarFrame.height
        } else {
            navBarFrame.origin.y = 0
        }
        
        self.containerBar.statusBarHeight = statusBarHeight
        self.containerBar.frame = navBarFrame
        
        if self.config.isTranslucent || self.containerBar.isHidden {
            self.unwarpNavigationController.view.frame = self.view.bounds
        } else {
            self.unwarpNavigationController.view.frame = .init(x: 0, y: self.containerBar.frame.maxY, width: self.view.frame.width, height: self.view.frame.height - self.containerBar.frame.maxY)
        }
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
    open override func setNeedsStatusBarAppearanceUpdate() {
        super.setNeedsStatusBarAppearanceUpdate()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
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
extension PKUINavigationContainerViewController: UIGestureRecognizerDelegate {
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
extension PKUINavigationContainerViewController {
    
    open class BackItemButton: UIButton {
        // 避免返回按钮看起来不靠左
        open override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
            var rect = super.imageRect(forContentRect: contentRect)
            rect.origin.x = 0
            return rect
        }
    }
}

// MARK: - Extension UIViewController.PL.LHWrapNavigationContainerViewController
extension PK where Base: UIViewController {
    
    /// 导航栏配置 只有当前vc 进入nav之后才有效
    public var navigationConfig: PKUINavigationConfig? {
        
        if let container = self.base.navigationController?.parent as? PKUINavigationContainerViewController {
            return container.config
        }
        
        if let container = self.base.parent as? PKUINavigationContainerViewController {
            return container.config
        }
        
        if let container = self.base as? PKUINavigationContainerViewController {
            return container.config
        }
        
        return nil
    }
    
    /// 获取解包之后的vc
    public var containerContentViewController: UIViewController {
        if let container = self.base as? PKUINavigationContainerViewController {
            return container.content
        }
        return self.base
    }
}
