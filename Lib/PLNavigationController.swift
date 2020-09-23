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
    
    /// 固定状态栏高度 用于设置导航栏高度 避免隐藏状态栏 导航栏会上移 不设置有默认逻辑
    struct StatusBarConfig {
        var portraitHeight: CGFloat?
        var landscapeHeight: CGFloat?
    }
    var statusBarConfig = StatusBarConfig() {
        didSet {
            self.visibleViewController?.view.setNeedsLayout()
        }
    }
    
    // push/pop 完成回调
    fileprivate var transitionCompleteCallback: Complete?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // 从xib 过来的需要重置一下
        self.setViewControllers(self.viewControllers, animated: false)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.setNavigationBarHidden(true, animated: false)
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
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers.map({
            
            if let container = $0 as? ContainerController {
                if container.isPushed {
                    return container
                }
            }
            
            let vc = ContainerController.init(content: $0)
            vc.isPushed = true
            return vc
        }), animated: animated)
    }
    
    // MARK: - PUSH And POP
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if viewController != self.viewControllers.last && viewController.navigationController == nil {
        
            /*
             animated 为true的时候
             可能同一个viewController 会走2次这个方法
             */
            if let container = viewController as? ContainerController, container.isPushed {
                return super.pushViewController(container, animated: animated)
            }
            
            let container = ContainerController.init(content: viewController)
            container.isPushed = true
            super.pushViewController(container, animated: animated)
        }
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        let vc = super.popViewController(animated: animated)
        return vc?.pl_containerContentViewController
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        let vcs = super.popToRootViewController(animated: animated)
        return vcs?.map({ $0.pl_containerContentViewController })
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        
        var vcs: [UIViewController]?
        if let container = viewController.navigationController?.parent as? ContainerController {
            if self.viewControllers.contains(container) {
                vcs = super.popToViewController(container, animated: animated)
            }

        } else if let container = viewController.parent as? ContainerController {
            if self.viewControllers.contains(container) {
                vcs = super.popToViewController(container, animated: animated)
            }
            
        } else {
            if self.viewControllers.contains(viewController) {
                vcs = super.popToViewController(viewController, animated: animated)
            }
        }
        
        return vcs?.map({ $0.pl_containerContentViewController })
    }
    
    // MARK: - UINavigationControllerDelegate
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        self.resetInteractivePopGestureRecognizer()
        
        self.transitionCompleteCallback?()
        self.transitionCompleteCallback = nil
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
    
    override var prefersStatusBarHidden: Bool {
        return self.visibleViewController?.prefersStatusBarHidden ?? false
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
        
        // 当前容器是否已经push进navigationController
        fileprivate var isPushed: Bool = false
        
        private(set) var conNavigationController: ContainerNavigationController!
        private(set) var content: UIViewController!
        
        private(set) var isNavigationBarHidden: Bool = false
        private(set) var warpNavigationBar: WarpNavigationBar!
        
        fileprivate(set) var isDisablePopGestureRecognizer = false
        
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
            
            self.conNavigationController = ContainerNavigationController.init(rootViewController: self.content)
            self.addChild(self.conNavigationController)
        }
        
        deinit {
            // 需要手动释放 不会自动释放 系统的没这个问题 不知什么原因
            self.content.navigationItem.leftBarButtonItems = nil
            self.content.navigationItem.rightBarButtonItems = nil
            self.content.navigationItem.backBarButtonItem = nil
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            guard self.content != nil else {
                return
            }
            
            // -- 当前不是第一个才加入返回按钮
            if self != self.navigationController?.viewControllers.first {
                
                // -- back item
                if let item = self.content.pl_configNavigationCustomBackItem(target: self, action: #selector(backBarButtonItemClick)) {
                    self.content.navigationItem.leftBarButtonItem = item
                } else {
                    
                    let backButton = BackItemButton(type: .system)
                    
                    if let image = self.content.pl_configNavigationCustomBackItemImage() {
                        backButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
                        backButton.frame.size = .init(width: image.size.width + 19, height: 44)
                    } else if let image = UIImage.init(named: "nav_back") {
                        backButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
                        backButton.frame.size = .init(width: image.size.width + 19, height: 44)
                    }
                    
                    backButton.addTarget(self, action: #selector(backBarButtonItemClick), for: .touchUpInside)
                    
                    // 直接使用 .init(image: ) 在 iOS11以上 与 iOS11以下 表现不一样
                    self.content.navigationItem.leftBarButtonItem = .init(customView: backButton)
                }
            }
            
            // --
            self.content.pl_configNavigationBar(self.warpNavigationBar.navigationBar)
            self.warpNavigationBar.navigationBar.pushItem(self.content.navigationItem, animated: false)
            
            // -- 先调整frame
            self.view.layoutIfNeeded()
            
            self.view.addSubview(self.conNavigationController.view)
            self.view.addSubview(self.warpNavigationBar)
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
        }
        
        override func viewWillLayoutSubviews() {
            super.viewWillLayoutSubviews()
            self.pl.navigationController?.statusBarConfig.landscapeHeight = 0
            
            if let nav = self.navigationController as? PLNavigationController {
                var navBarFrame = CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: 44)
                
                let isPortrait = UIDevice.current.orientation.isPortrait
                let h = isPortrait ? nav.statusBarConfig.portraitHeight : nav.statusBarConfig.landscapeHeight
                
                if let statusBarHeight = h {
                    navBarFrame.size.height += statusBarHeight
                    
                } else if #available(iOS 11.0, *) {
                    
                    if self.view.safeAreaInsets.bottom > 0 {
                        // 全面屏不会出现状态栏上移的问题直接取系统状态栏高度
                        navBarFrame.size.height += UIApplication.shared.statusBarFrame.height
                    } else {
                        // 非全面屏固定20
                        navBarFrame.size.height += isPortrait ? 20 : 0
                    }
                } else {
                    navBarFrame.size.height += isPortrait ? 20 : 0
                }
                
                if self.isNavigationBarHidden {
                    navBarFrame.origin.y = -navBarFrame.height
                } else {
                    navBarFrame.origin.y = 0
                }
                
                self.warpNavigationBar.frame = navBarFrame
            }
            
            self.conNavigationController.view.frame = self.view.bounds
        }
        
        @objc fileprivate func backBarButtonItemClick() {
            self.navigationController?.popViewController(animated: true)
        }
        
        func setNavigationBarHidden(_ isHidden: Bool, animated: Bool) {
            guard self.isNavigationBarHidden != isHidden else {
                return
            }
            self.isNavigationBarHidden = isHidden
            if animated {
                var frame = self.warpNavigationBar.frame
                frame.origin.y = isHidden ? -frame.size.height : 0
                UIView.animate(withDuration: 0.25) {
                    self.warpNavigationBar.frame = frame
                    
                }
            } else {
                self.warpNavigationBar.isHidden = isHidden
            }
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
            return self.conNavigationController
        }
        
        override var childForStatusBarHidden: UIViewController? {
            return self.conNavigationController
        }
        
        override var childForHomeIndicatorAutoHidden: UIViewController? {
            return self.conNavigationController
        }
        
        override var childForScreenEdgesDeferringSystemGestures: UIViewController? {
            return self.conNavigationController
        }
        
        override var prefersStatusBarHidden: Bool {
            return self.conNavigationController?.prefersStatusBarHidden ?? false
        }
        
        override var preferredStatusBarStyle: UIStatusBarStyle {
            return self.conNavigationController?.preferredStatusBarStyle ?? .default
        }
        
        override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
            return self.conNavigationController?.preferredStatusBarUpdateAnimation ?? .fade
        }
        
        override var shouldAutorotate: Bool {
            return self.conNavigationController?.shouldAutorotate ?? false
        }
        
        override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
            return self.conNavigationController?.preferredInterfaceOrientationForPresentation ?? .portrait
        }
        
        override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return self.conNavigationController?.supportedInterfaceOrientations ?? .portrait
        }
    }
    
    // MARK: - Class ContainerNavigationController
    class ContainerNavigationController: UINavigationController {
        
        override func viewDidLoad() {
            super.viewDidLoad()
            super.setNavigationBarHidden(true, animated: false)
            self.interactivePopGestureRecognizer?.isEnabled = false
        }
        
        override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
            
            if let container = self.parent as? ContainerController {
                container.setNavigationBarHidden(hidden, animated: animated)
            } else {
                super.setNavigationBarHidden(hidden, animated: animated)
            }
        }
        
        override var isNavigationBarHidden: Bool {
            set {
                if let container = self.parent as? ContainerController {
                    container.setNavigationBarHidden(newValue, animated: false)
                } else {
                    super.isNavigationBarHidden = newValue
                }
            }
            
            get {
                if let container = self.parent as? ContainerController {
                    return container.isNavigationBarHidden
                } else {
                    return super.isNavigationBarHidden
                }
            }
        }
        
        override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
            if self.navigationController != nil {
                self.navigationController?.setViewControllers(viewControllers, animated: animated)
            } else {
                super.setViewControllers(viewControllers, animated: animated)
            }
        }
        
        override var viewControllers: [UIViewController] {
            set {
                if self.navigationController != nil {
                    self.navigationController?.viewControllers = newValue
                } else {
                    super.viewControllers = newValue
                }
            }
            get {
                if self.navigationController != nil {
                    return self.navigationController!.viewControllers.map({ $0.pl_containerContentViewController })
                } else {
                    return super.viewControllers
                }
            }
        }

        override func forwardingTarget(for aSelector: Selector!) -> Any? {
            if self.navigationController != nil {
                return self.navigationController?.forwardingTarget(for: aSelector)
            } else {
                return super.forwardingTarget(for: aSelector)
            }
        }
        
        override func pushViewController(_ viewController: UIViewController, animated: Bool) {
            if self.navigationController != nil {
                self.navigationController?.pushViewController(viewController, animated: animated)
            } else {
                super.pushViewController(viewController, animated: animated)
            }
        }
        
        override func popViewController(animated: Bool) -> UIViewController? {
            if self.navigationController != nil {
                return self.navigationController?.popViewController(animated: animated)
            } else {
                return super.popViewController(animated: animated)
            }
        }
        
        override func popToRootViewController(animated: Bool) -> [UIViewController]? {
            if self.navigationController != nil {
                return self.navigationController?.popToRootViewController(animated: animated)
            } else {
                return super.popToRootViewController(animated: animated)
            }
        }
        
        override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
            if self.navigationController != nil {
                return self.navigationController?.popToViewController(viewController, animated: animated)
            } else {
                return super.popToViewController(viewController, animated: animated)
            }
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
        
        override var prefersStatusBarHidden: Bool {
            return self.visibleViewController?.prefersStatusBarHidden ?? false
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
    }
}


extension PLNavigationController {
    // MARK: - Class WarpNavigationBar
    class WarpNavigationBar: UIView {
        
        fileprivate(set) var barHeight: CGFloat = 44
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
            self.navigationBar.frame = .init(x: 0, y: self.frame.height - self.barHeight, width: self.frame.width, height: self.barHeight)
        }
    }
}


// MARK: - Extension UINavigationController
extension UINavigationController {
    
    var pl_viewControllers: [UIViewController]? {
        if let nav = self as? PLNavigationController {
            return nav.viewControllers.map({ $0.pl_containerContentViewController })
        }
        return self.navigationController?.pl_viewControllers
    }
    
    var pl_topViewController: UIViewController? {
        if let nav = self as? PLNavigationController {
            return nav.topViewController?.pl_containerContentViewController
        }
        return self.navigationController?.pl_topViewController
    }
    
    var pl_visiableViewController: UIViewController? {
        if let nav = self as? PLNavigationController {
            return nav.visibleViewController?.pl_containerContentViewController
        }
        return self.navigationController?.pl_visiableViewController
    }
    
    /// 移除一个viewController
    /// - Parameter viewController:
    /// - Returns:
    @discardableResult
    func removeViewController(_ viewController: UIViewController?) -> UIViewController?  {
        
        guard let viewController = viewController else {
            return nil
        }
        
        if let nav = self as? PLNavigationController {
            
            for (idx, container) in nav.viewControllers.enumerated() {
                
                // 传进来的是 ContainerController
                if container == viewController {
                    nav.viewControllers.remove(at: idx)
                    return (container as? PLNavigationController.ContainerController)?.content ?? container
                }
                
                // 传进来的是其他的
                if let container = container as? PLNavigationController.ContainerController {
                    if container.content == viewController {
                        nav.viewControllers.remove(at: idx)
                        return container.content
                    }
                }
            }
        } else {
            return self.navigationController?.removeViewController(viewController)
        }
        
        return nil
    }
    
    
    func pushViewController(_ viewController: UIViewController, animated: Bool, complete: PLNavigationController.Complete?) {
        if let nav = self as? PLNavigationController {
            nav.transitionCompleteCallback = complete
            nav.pushViewController(viewController, animated: animated)
        } else {
            self.navigationController?.pushViewController(viewController, animated: animated, complete: complete)
        }
    }
    
    func popViewController(animated: Bool, complete: PLNavigationController.Complete?) -> UIViewController? {
        if let nav = self as? PLNavigationController {
            nav.transitionCompleteCallback = complete
            return nav.popViewController(animated: animated)
        } else {
            return self.navigationController?.popViewController(animated: animated, complete: complete)
        }
    }
    
    func popToRootViewController(animated: Bool, complete: PLNavigationController.Complete?) -> [UIViewController]? {
        if let nav = self as? PLNavigationController {
            nav.transitionCompleteCallback = complete
            return nav.popToRootViewController(animated: animated)
        } else {
            return self.navigationController?.popToRootViewController(animated: animated, complete: complete)
        }
    }
    
    func popToViewController(_ viewController: UIViewController, animated: Bool, complete: PLNavigationController.Complete?) -> [UIViewController]? {
        if let nav = self as? PLNavigationController {
            nav.transitionCompleteCallback = complete
            return nav.popToViewController(viewController, animated: animated)
        } else {
            return self.navigationController?.popToViewController(viewController, animated: animated, complete: complete)
        }
    }
}

// MARK: - Extension UIViewController.PL.navigationController
extension PL where Base: UIViewController {
    
    /*
     这里取到是根部NavigationController 与 self.navigationController 不一样
     通过 self.navigationController 调用 viewControllers 得到的viewController 都是unpack之后的
     通过该属性调用得到的viewController 都是 ContainerController
     topViewController 和 visiableViewController 使用pl_开头的属性
     */
    var navigationController: PLNavigationController? {
        return self.base.navigationController?.navigationController as? PLNavigationController
    }
    
    var navigationBar: PLNavigationController.WarpNavigationBar? {
        if let container = self.base.navigationController?.parent as? PLNavigationController.ContainerController {
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
    @objc optional func pl_configNavigationCustomBackItemImage() -> UIImage?
    
    /// 自定义返回按钮
    @objc optional func pl_configNavigationCustomBackItem(target: Any, action: Selector) -> UIBarButtonItem?
    
    /// 设置导航栏
    /// - Parameter bar:
    @objc optional func pl_configNavigationBar(_ bar: UINavigationBar)
    
    /// 是否屏蔽返回手势
    var pl_isDisablePopGestureRecognizer: Bool { set get }
}

extension UIViewController: PLNavigationControllerConfig {
    func pl_configNavigationCustomBackItemImage() -> UIImage? {
        return nil
    }
    
    func pl_configNavigationCustomBackItem(target: Any, action: Selector) -> UIBarButtonItem? {
        return nil
    }
    
    func pl_configNavigationBar(_ bar: UINavigationBar) {
        
    }
    
    var pl_isDisablePopGestureRecognizer: Bool {
        get {
            return (self.navigationController?.parent as? PLNavigationController.ContainerController)?.isDisablePopGestureRecognizer ?? false
        }
        
        set {
            (self.navigationController?.parent as? PLNavigationController.ContainerController)?.isDisablePopGestureRecognizer = newValue
        }
    }
}


// MARK: - Unwarp
extension UIViewController {
    var pl_containerContentViewController: UIViewController {
        if let container = self as? PLNavigationController.ContainerController {
            return container.content
        }
        return self
    }
}
