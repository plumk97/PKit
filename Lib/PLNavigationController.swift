//
//  PLNavigationController.swift
//  PLKit
//
//  Created by iOS on 2020/5/8.
//  Copyright © 2020 iOS. All rights reserved.
//

import UIKit



// MARK: - Class PLNavigationController
class PLNavigationController: UINavigationController, UINavigationControllerDelegate {
    typealias Complete = () -> Void
    
    fileprivate var transitionCompleteCallback: Complete?
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setViewControllers(self.viewControllers.map({ ContainerController.init(content: $0) }), animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarHidden(true, animated: false)
        self.delegate = self
    }
    
    
    /// 重新设置手势代理
    fileprivate func resetInteractivePopGestureRecognizer() {
        
        var vc: ContainerController?
        defer {
            if let vc = vc {
                self.interactivePopGestureRecognizer?.delegate = vc
                self.interactivePopGestureRecognizer?.isEnabled = true
            } else {
                self.interactivePopGestureRecognizer?.delegate = nil
                self.interactivePopGestureRecognizer?.isEnabled = false
            }
        }
        
        guard self.viewControllers.count > 1 else {
            return
        }
        
        vc = self.viewControllers.last as? ContainerController
    }
    
    /// 移除一个viewController
    /// - Parameter viewController:
    /// - Returns:
    @discardableResult
    func removeViewController(_ viewController: UIViewController?) -> UIViewController?  {
        guard let viewController = viewController else {
            return nil
        }
        for (idx, container) in self.viewControllers.enumerated() {
            if let container = container as? ContainerController {
                if container.content == viewController {
                    
                    self.viewControllers.remove(at: idx)
                    return container.content
                }
            }
        }
        return nil
    }
    
    // MARK: - Child
    override var childForStatusBarStyle: UIViewController? {
        return self.visibleViewController
    }
    
    override var childForStatusBarHidden: UIViewController? {
        return self.visibleViewController
    }
    
    override var childForHomeIndicatorAutoHidden: UIViewController? {
        return self.visibleViewController
    }
    
    override var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        return self.visibleViewController
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.visibleViewController?.preferredStatusBarStyle ?? .default
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return self.visibleViewController?.preferredStatusBarUpdateAnimation ?? .fade
    }
    
    override var shouldAutorotate: Bool {
        return self.visibleViewController?.shouldAutorotate ?? false
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return self.visibleViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.visibleViewController?.supportedInterfaceOrientations ?? .portrait
    }
    
    // MARK: - PUSH And POP
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        let container = ContainerController.init(content: viewController)
        super.pushViewController(container, animated: animated)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        return super.popViewController(animated: animated)
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        return super.popToRootViewController(animated: animated)
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        return super.popToViewController(viewController, animated: animated)
    }
    
    
    // -- completion callback
    func pushViewController(_ viewController: UIViewController, animated: Bool, complete: Complete?) {
        self.transitionCompleteCallback = complete
        return self.pushViewController(viewController, animated: animated)
    }
    
    func popViewController(animated: Bool, complete: Complete?) -> UIViewController? {
        self.transitionCompleteCallback = complete
        return self.popViewController(animated: animated)
    }
    
    func popToRootViewController(animated: Bool, complete: Complete?) -> [UIViewController]? {
        self.transitionCompleteCallback = complete
        return self.popToRootViewController(animated: animated)
    }
    
    func popToViewController(_ viewController: UIViewController, animated: Bool, complete: Complete?) -> [UIViewController]? {
        self.transitionCompleteCallback = complete
        return self.popToViewController(viewController, animated: animated)
    }
    
    // MARK: - UINavigationControllerDelegate
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        self.resetInteractivePopGestureRecognizer()
        
        self.transitionCompleteCallback?()
        self.transitionCompleteCallback = nil
    }
}


extension PLNavigationController {
    // MARK: - Class ContainerController
    class ContainerController: UIViewController, UIGestureRecognizerDelegate {
        
        class BackItemButton: UIButton {
            // 避免返回按钮看起来不靠左
            override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
                var rect = super.imageRect(forContentRect: contentRect)
                rect.origin.x = 0
                return rect
            }
        }
        
        var content: UIViewController!
        var warpNavigationBar: WarpNavigationBar!
        
        var isDisablePopGestureRecognizer = false
        
        init(content: UIViewController) {
            super.init(nibName: nil, bundle: nil)
            
            self.content = content
            self.commInit()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            self.commInit()
        }
        
        fileprivate func commInit() {
            
            self.warpNavigationBar = WarpNavigationBar()
            
            guard self.content != nil else {
                return
            }
            self.addChild(self.content)
        }
        deinit {
            // 需要手动释放 不会自动释放 系统的没这个问题 不知什么原因
            self.navigationItem.leftBarButtonItems = nil
            self.navigationItem.rightBarButtonItems = nil
            self.navigationItem.backBarButtonItem = nil
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            if self != self.navigationController?.viewControllers.first {
                
                // -- back item
                if let item = self.content.pl_navigationCustomBackItem(target: self, action: #selector(backBarButtonItemClick)) {
                    self.navigationItem.leftBarButtonItem = item
                } else {
                    
                    let backButton = BackItemButton(type: .system)
                    
                    if let image = self.content.pl_navigationCustomBackItemImage() {
                        backButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
                        backButton.frame.size = .init(width: image.size.width + 19, height: 44)
                    } else if let image = UIImage.init(named: "nav_back") {
                        backButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
                        backButton.frame.size = .init(width: image.size.width + 19, height: 44)
                    }
                    
                    backButton.addTarget(self, action: #selector(backBarButtonItemClick), for: .touchUpInside)
                    
                    // 直接使用 .init(image: ) 在 iOS11以上 与 iOS11以下 表现不一样
                    self.navigationItem.leftBarButtonItem = .init(customView: backButton)
                }
            }
            self.content.pl_setupNavigationBar(self.warpNavigationBar.navigationBar)
            self.warpNavigationBar.navigationBar.pushItem(self.navigationItem, animated: false)
            
            // -- navigation bar frame
            let statusBarFrame = UIApplication.shared.statusBarFrame
            self.warpNavigationBar.frame = .init(x: 0, y: 0, width: self.view.frame.width, height: 44 + statusBarFrame.height)
            
            
            self.view.addSubview(self.content.view)
            self.view.addSubview(self.warpNavigationBar)
        }
        
        
        override var navigationItem: UINavigationItem {
            return self.content.navigationItem
        }
        
        @objc fileprivate func backBarButtonItemClick() {
            self.navigationController?.popViewController(animated: true)
        }
        
        // MARK: - UIGestureRecognizerDelegate
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer else {
                return true
            }
            return !self.isDisablePopGestureRecognizer
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer
        }
        
        // MARK: - Child
        override var childForStatusBarStyle: UIViewController? {
            return self.content
        }
        
        override var childForStatusBarHidden: UIViewController? {
            return self.content
        }
        
        override var childForHomeIndicatorAutoHidden: UIViewController? {
            return self.content
        }
        
        override var childForScreenEdgesDeferringSystemGestures: UIViewController? {
            return self.content
        }
        
        override var preferredStatusBarStyle: UIStatusBarStyle {
            return self.content?.preferredStatusBarStyle ?? .default
        }
        
        override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
            return self.content?.preferredStatusBarUpdateAnimation ?? .fade
        }
        
        override var shouldAutorotate: Bool {
            return self.content?.shouldAutorotate ?? false
        }
        
        override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
            return self.content?.preferredInterfaceOrientationForPresentation ?? .portrait
        }
        
        override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return self.content?.supportedInterfaceOrientations ?? .portrait
        }
    }
}


extension PLNavigationController {
    // MARK: - Class WarpNavigationBar
    class WarpNavigationBar: UIView {
        
        private(set) var navigationBar: UINavigationBar!
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.commInit()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            self.commInit()
        }
        
        fileprivate func commInit() {
            
            self.backgroundColor = UIColor.white
            
            self.navigationBar = UINavigationBar()
            self.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.addSubview(self.navigationBar)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            self.navigationBar.frame = .init(x: 0, y: self.frame.height - 44, width: self.frame.width, height: 44)
        }
    }
}


// MARK: - Extension UIViewController.PL.navigationController
extension PL where Base: UIViewController {
    
    var navigationController: PLNavigationController? {
        return self.base.navigationController as? PLNavigationController
    }
    
    var navigationBar: PLNavigationController.WarpNavigationBar? {
        if let container = self.base.parent as? PLNavigationController.ContainerController {
            return container.warpNavigationBar
        }
        
        if let container = self.base as? PLNavigationController.ContainerController {
            return container.warpNavigationBar
        }
        
        return nil
    }
}

// MARK: - PLNavigationControllerConfig
@objc protocol PLNavigationControllerConfig {
    
    /// 自定义返回按钮图片
    @objc optional func pl_navigationCustomBackItemImage() -> UIImage?
    
    /// 自定义返回按钮
    @objc optional func pl_navigationCustomBackItem(target: Any, action: Selector) -> UIBarButtonItem?
    
    /// 设置导航栏
    /// - Parameter bar:
    @objc optional func pl_setupNavigationBar(_ bar: UINavigationBar)
    
    /// 是否屏蔽返回手势
    var pl_isDisablePopGestureRecognizer: Bool { set get }
}

extension UIViewController: PLNavigationControllerConfig {
    func pl_navigationCustomBackItemImage() -> UIImage? {
        return nil
    }
    
    func pl_navigationCustomBackItem(target: Any, action: Selector) -> UIBarButtonItem? {
        return nil
    }
    
    func pl_setupNavigationBar(_ bar: UINavigationBar) {
        
    }
    
    var pl_isDisablePopGestureRecognizer: Bool {
        get {
            return (self.parent as? PLNavigationController.ContainerController)?.isDisablePopGestureRecognizer ?? false
        }
        
        set {
            (self.parent as? PLNavigationController.ContainerController)?.isDisablePopGestureRecognizer = newValue
        }
    }
}
