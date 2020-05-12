//
//  PLTabBarController.swift
//  PLKit
//
//  Created by iOS on 2019/8/7.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

// MARK: - PLTabBarControllerDelegate
@objc protocol PLTabBarControllerDelegate: NSObjectProtocol {
    
    /// 是否能选中某个ViewController 返回false则不选中
    /// - Parameters:
    ///   - tabBarController:
    ///   - index:
    @objc optional func tabBarController(_ tabBarController: PLTabBarController, shouldSelect index: Int) -> Bool
    
    /// 选中某个ViewController
    /// - Parameters:
    ///   - tabBarController:
    ///   - index:
    @objc optional func tabBarController(_ tabBarController: PLTabBarController, didSelect index: Int)
    
    /// 某个ViewController.TabBarItem 被双击
    /// - Parameters:
    ///   - tabBarController:
    ///   - index:
    @objc optional func tabBarController(_ tabBarController: PLTabBarController, didDoubleTap index: Int)
}

// MARK: - PLTabBarController
class PLTabBarController: UIViewController {
    
    weak var delegate: PLTabBarControllerDelegate?
    
    var viewControllers: [UIViewController]? { didSet { self.reloadViewControllers(oldValue) }}
    
    private(set) var selectedIndex: Int = 0
    /// 当前选中的viewContnroler
    private(set) weak var selectedViewController: UIViewController?
    
    /// TabBar 内容高度 不要使用tabBar设置
    var tabBarHeight: CGFloat = 54 { didSet { self.view.setNeedsLayout() } }
    
    private(set) var tabBar = PLTabBar()
    private var bodyView: UIView!
    
    private var isNeedReloadAfterLoaded = false
    
    override var childForStatusBarStyle: UIViewController? {
        return self.selectedViewController
    }
    override var childForStatusBarHidden: UIViewController? {
        return self.selectedViewController
    }
    
    override func viewDidLoad() {
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.bodyView.frame = self.view.bounds
        
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
        
        var items = [PLTabBarItem]()
        for vc in viewControllers {
            self.addChild(vc)
            items.append(vc.pl.tabBarItem)
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
        self.bodyView.addSubview(new.view)
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    /// 设置选中ViewController下标
    /// - Parameters:
    ///   - index:
    ///   - animation:
    func setSelectedIndex(_ index: Int, animation: Bool) {
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

// MARK: - PLTabBarDelegate
extension PLTabBarController: PLTabBarDelegate {
    
    internal func tabBar(_ tabBar: PLTabBar, willSelect index: Int) -> Bool {
        return self.delegate?.tabBarController?(self, shouldSelect: index) ?? true
    }
    
    internal func tabBar(_ tabBar: PLTabBar, didSelect index: Int) {
        self.setSelectedIndex(index, animation: true, isTabBarSelect: true)
        self.delegate?.tabBarController?(self, didSelect: index)
    }
    
    internal func tabBar(_ tabBar: PLTabBar, didDoubleTap index: Int) {
        self.delegate?.tabBarController?(self, didDoubleTap: index)
    }
}

// MARK: - Extension UIViewController.PL.tabBarController
extension PL where Base: UIViewController {
    var tabBarController: PLTabBarController? {
        var parent = self.base.parent
        while parent != nil && !(parent is PLTabBarController) {
            parent = parent?.parent
        }
        return parent as? PLTabBarController

    }
}
