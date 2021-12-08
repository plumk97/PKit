//
//  PLUnwrapNavigationController.swift
//  PKit
//
//  Created by Plumk on 2021/11/4.
//

import UIKit

open class PLUnwrapNavigationController: UINavigationController {

    var containerViewController: PLNavigationContainerViewController? {
        return self.parent as? PLNavigationContainerViewController
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        super.setNavigationBarHidden(true, animated: false)
        self.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    open override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        self.containerViewController?.setNavigationBarHidden(hidden, animated: animated)
    }
    
    open override var isNavigationBarHidden: Bool {
        set {
            self.containerViewController?.setNavigationBarHidden(newValue, animated: false)
        }
        
        get {
            self.containerViewController?.isNavigationBarHidden ?? false
        }
    }
    
    open override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        if let nav = self.navigationController {
            nav.setViewControllers(viewControllers, animated: animated)
        } else {
            super.setViewControllers(viewControllers, animated: animated)
        }
    }
    
    open override var viewControllers: [UIViewController] {
        set {
            if let nav = self.navigationController {
                nav.viewControllers = viewControllers
            } else {
                super.viewControllers = newValue
            }
        }
        get {
            if let nav = self.navigationController {
                return nav.viewControllers.map({ $0.pl.containerContentViewController })
            } else {
                return super.viewControllers
            }
        }
    }

    open override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if let nav = self.navigationController {
            return nav.forwardingTarget(for: aSelector)
        } else {
            return super.forwardingTarget(for: aSelector)
        }
    }
    
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if let nav = self.navigationController {
            nav.pushViewController(viewController, animated: animated)
        } else {
            super.pushViewController(viewController, animated: animated)
        }
    }
    
    open override func popViewController(animated: Bool) -> UIViewController? {
        if let nav = self.navigationController {
            return nav.popViewController(animated: animated)?.pl.containerContentViewController
        } else {
            return super.popViewController(animated: animated)
        }
        
    }
    
    open override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        
        if let nav = self.navigationController {
            return nav.popToRootViewController(animated: animated)?.map({ $0.pl.containerContentViewController })
        } else {
            return super.popToRootViewController(animated: animated)
        }
    }
    
    open override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        
        if let nav = self.navigationController {
            guard let containerViewController = viewController.navigationController?.parent else {
                return nil
            }
            
            return nav.popToViewController(containerViewController, animated: animated)?.map({ $0.pl.containerContentViewController })
        } else {
            
            return super.popToViewController(viewController, animated: animated)
        }
    }
    
    // MARK: - Child
    open override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
    
    open override var childForStatusBarHidden: UIViewController? {
        return self.topViewController
    }
    
    open override var childForHomeIndicatorAutoHidden: UIViewController? {
        return self.topViewController
    }
    
    open override var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        return self.topViewController
    }
    
    open override var prefersStatusBarHidden: Bool {
        return self.topViewController?.prefersStatusBarHidden ?? false
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.topViewController?.preferredStatusBarStyle ?? .default
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return self.topViewController?.preferredStatusBarUpdateAnimation ?? .fade
    }
    
    open override var shouldAutorotate: Bool {
        return self.topViewController?.shouldAutorotate ?? false
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return self.topViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.topViewController?.supportedInterfaceOrientations ?? .portrait
    }
}


// MARK: - Extension UINavigationController
extension UINavigationController {

    /// 移除一个viewController
    /// - Parameter viewController:
    /// - Returns:
    @discardableResult
    open func removeViewController(_ viewController: UIViewController?) -> UIViewController?  {

        func _removeViewController(_ navigationController: UINavigationController, viewController: UIViewController) -> UIViewController? {
            if let idx = navigationController.viewControllers.firstIndex(of: viewController) {
                return navigationController.viewControllers.remove(at: idx)
            }
            return nil
        }
        
        if let nav = self.pl.navigationController, let vc = viewController?.navigationController?.parent {
            return _removeViewController(nav, viewController: vc)
        } else if let nav = viewController?.navigationController, let vc = viewController {
            return _removeViewController(nav, viewController: vc)
        }
        return nil
    }


    open func pushViewController(_ viewController: UIViewController, animated: Bool, complete: PLNavigationController.TransitionCompleteCallback?) {
        
        if let nav = self.pl.navigationController {
            nav.transitionCompleteCallback = complete
            nav.pushViewController(viewController, animated: animated)
        } else {
            self.pushViewController(viewController, animated: animated)
        }
    }

    open func popViewController(animated: Bool, complete: PLNavigationController.TransitionCompleteCallback?) -> UIViewController? {
        if let nav = self.pl.navigationController {
            nav.transitionCompleteCallback = complete
            return nav.popViewController(animated: animated)?.pl.containerContentViewController
        } else {
            return self.popViewController(animated: animated)
        }
    }

    open func popToRootViewController(animated: Bool, complete: PLNavigationController.TransitionCompleteCallback?) -> [UIViewController]? {
        if let nav = self.pl.navigationController {
            nav.transitionCompleteCallback = complete
            return nav.popToRootViewController(animated: animated)?.map({ $0.pl.containerContentViewController })
        } else {
            return self.popToRootViewController(animated: animated)
        }
    }

    open func popToViewController(_ viewController: UIViewController, animated: Bool, complete: PLNavigationController.TransitionCompleteCallback?) -> [UIViewController]? {
        if let nav = self.pl.navigationController, let vc = viewController.navigationController?.parent {
            nav.transitionCompleteCallback = complete
            return nav.popToViewController(vc, animated: animated)?.map({ $0.pl.containerContentViewController })
        } else {
            return self.popToViewController(viewController, animated: animated)
        }
    }
}
