//
//  PKUITabBarController.swift
//  PKit
//
//  Created by Plumk on 2019/8/7.
//  Copyright © 2019 Plumk. All rights reserved.
//

import UIKit

// MARK: - PKUITabBarControllerDelegate
@objc public protocol PKUITabBarControllerDelegate: NSObjectProtocol {
    
    /// 是否能选中某个ViewController 返回false则不选中
    /// - Parameters:
    ///   - tabBarController:
    ///   - index:
    @objc optional func tabBarController(_ tabBarController: PKUITabBarController, shouldSelect index: Int) -> Bool
    
    /// 选中某个ViewController
    /// - Parameters:
    ///   - tabBarController:
    ///   - index:
    @objc optional func tabBarController(_ tabBarController: PKUITabBarController, didSelect index: Int)
    
    /// 某个ViewController.TabBarItem 被双击
    /// - Parameters:
    ///   - tabBarController:
    ///   - index:
    @objc optional func tabBarController(_ tabBarController: PKUITabBarController, didDoubleTap index: Int)
}

// MARK: - PKUITabBarController
open class PKUITabBarController: UIViewController {
    
    open weak var delegate: PKUITabBarControllerDelegate?
    
    open var viewControllers: [UIViewController]? { didSet { self.reloadViewControllers(oldValue) }}
    
    open private(set) var selectedIndex: Int = 0
    /// 当前选中的viewContnroler
    open private(set) weak var selectedViewController: UIViewController?
    
    /// TabBar 内容高度 不要使用tabBar设置
    open var tabBarHeight: CGFloat = 54 { didSet { self.view.setNeedsLayout() } }
    
    open private(set) var tabBar = PKUITabBar()
    private var bodyView: UIView!
    
    private var isNeedReloadAfterLoaded = false
    
    open override var childForStatusBarStyle: UIViewController? {
        return self.selectedViewController
    }
    open override var childForStatusBarHidden: UIViewController? {
        return self.selectedViewController
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bodyView = UIView.init(frame: self.view.bounds)
        self.bodyView.backgroundColor = .white
        self.view.addSubview(self.bodyView)
        
        self.tabBar.delegate = self
        self.view.addSubview(self.tabBar)
        
        if self.isNeedReloadAfterLoaded {
            self.reloadViewControllers(nil)
        }
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.bodyView.frame = self.view.bounds
        self.selectedViewController?.view.frame = self.bodyView.bounds
        
        var sumHeight = self.tabBarHeight
        if #available(iOS 11.0, *) {
            sumHeight += self.view.safeAreaInsets.bottom
        }
        
        self.tabBar.contentHeight = self.tabBarHeight
        self.tabBar.frame = .init(x: 0,
                                  y: self.view.bounds.height - sumHeight,
                                  width: self.view.bounds.width,
                                  height: sumHeight)
    }
    
    
    
    /// 重新加载ViewControllers
    /// - Parameter oldViewControllers:
    private func reloadViewControllers(_ oldViewControllers: [UIViewController]?) {
        
        // 如果当前视图没有加载完成 放到加载完成之后
        guard self.isViewLoaded else {
            self.isNeedReloadAfterLoaded = true
            return
        }
        
        oldViewControllers?.forEach({
            $0.view.removeFromSuperview()
            $0.removeFromParent()
        })
        
        guard let viewControllers = self.viewControllers else {
            return
        }
        
        var items = [PKUITabBarItem]()
        for vc in viewControllers {
            self.addChild(vc)
            items.append(vc.pk.tabBarItem)
        }
        self.tabBar.items = items
        self.setSelectedIndex(self.selectedIndex, animation: false)
    }
    
    /// 切换ViewController
    /// - Parameters:
    ///   - new:
    ///   - old:
    private func toggleViewController(new: UIViewController?, old: UIViewController?) {
        guard new != old && self.bodyView != nil else {
            return
        }
        
        old?.view.removeFromSuperview()
        
        guard let new = new else {
            return
        }
        self.selectedViewController = new
        new.view.frame = self.bodyView.bounds
        self.bodyView.addSubview(new.view)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    /// 设置选中ViewController下标
    /// - Parameters:
    ///   - index:
    ///   - animation:
    open func setSelectedIndex(_ index: Int, animation: Bool) {
        self.setSelectedIndex(index, animation: animation, isTabBarSelect: false)
    }
    
    /// 设置选中ViewController下标
    /// - Parameters:
    ///   - index:
    ///   - animation:
    ///   - isTabBarSelect: 是否是通过tabbar选中的
    private func setSelectedIndex(_ index: Int, animation: Bool, isTabBarSelect: Bool) {
        self.selectedIndex = index
        
        if !isTabBarSelect {
            self.tabBar.setSelectedIndex(index, animation: animation)
        }
        
        guard let viewControllers = self.viewControllers else {
            return
        }
        
        if index < viewControllers.count && index >= 0 {
            let vc = viewControllers[index]
            self.toggleViewController(new: vc, old: self.selectedViewController)
        }
    }
}

// MARK: - PKUITabBarDelegate
extension PKUITabBarController: PKUITabBarDelegate {
    
    open func tabBar(_ tabBar: PKUITabBar, willSelect index: Int) -> Bool {
        return self.delegate?.tabBarController?(self, shouldSelect: index) ?? true
    }
    
    open func tabBar(_ tabBar: PKUITabBar, didSelect index: Int) {
        self.setSelectedIndex(index, animation: true, isTabBarSelect: true)
        self.delegate?.tabBarController?(self, didSelect: index)
    }
    
    open func tabBar(_ tabBar: PKUITabBar, didDoubleTap index: Int) {
        self.delegate?.tabBarController?(self, didDoubleTap: index)
    }
}

// MARK: - Extension UIViewController.PL.tabBarController
extension PK where Base: UIViewController {
    public var tabBarController: PKUITabBarController? {
        var parent = self.base.parent
        while parent != nil && !(parent is PKUITabBarController) {
            parent = parent?.parent
        }
        return parent as? PKUITabBarController

    }
}
