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
    @objc optional func tabBarController(_ tabBarController: PLTabBarController, shouldSelect index: Int) -> Bool
    @objc optional func tabBarController(_ tabBarController: PLTabBarController, didSelect index: Int)
    @objc optional func tabBarController(_ tabBarController: PLTabBarController, didDoubleTap index: Int)
}

// MARK: - PLTabBarController
class PLTabBarController: UIViewController {

    weak var delegate: PLTabBarControllerDelegate?
    
    var viewControllers: [UIViewController]? {
        willSet { removeViewControllers() }
        didSet { reloadViewControllers() }
    }
    
    var selectedViewController: UIViewController? {
        guard let vcs = viewControllers else {
            return nil
        }
        if selectedIndex >= 0 && selectedIndex < vcs.count {
            return vcs[selectedIndex]
        }
        return nil
    }
    private(set) var selectedIndex: Int = 0
    
    var tabBarHeight: CGFloat = 54 { didSet{ renewTabBarFrame() } }
    private(set) var tabBar = PLTabBar()
    private var warpView: UIView!
    private var isNeedReloadAfterLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        warpView = UIView.init(frame: view.bounds)
        view.addSubview(warpView)
        
        tabBar.delegate = self
        view.addSubview(tabBar)
        
        if isNeedReloadAfterLoaded {
            reloadViewControllers()
            isNeedReloadAfterLoaded = false
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        warpView.frame = view.bounds
        renewTabBarFrame()
    }
    
    private func renewTabBarFrame() {
        var height = self.tabBarHeight
        if #available(iOS 11.0, *) {
            height += view.safeAreaInsets.bottom
        }
        
        let frame = CGRect.init(x: 0, y: view.bounds.height - height, width: view.bounds.width, height: height)
        tabBar.frame = frame
        tabBar.contentHeight = self.tabBarHeight
    }
    
    private func removeViewControllers() {
        self.viewControllers?.forEach({
            $0.removeFromParent()
            $0.view.removeFromSuperview()
        })
    }
    
    private func reloadViewControllers() {
        guard self.isViewLoaded else {
            isNeedReloadAfterLoaded = true
            return
        }
        
        viewControllers?.forEach({
            self.addChild($0)
            
        })
        tabBar.items = viewControllers?.map({$0.pl.tabBarItem})
        setSelectedIndex(selectedIndex)
        tabBar.setSelectedIndex(selectedIndex)
    }
    
    
    func setSelectedIndex(_ index: Int) {
        self.selectedViewController?.view.removeFromSuperview()
        self.selectedIndex = index
        self.tabBar.setSelectedIndex(index)
        guard self.warpView != nil else {
            return
        }
        
        if let view = self.selectedViewController?.view {
            self.warpView.addSubview(view)
        }
    }
}

extension PLTabBarController: PLTabBarDelegate {
    
    internal func tabBar(_ tabBar: PLTabBar, willSelect index: Int) -> Bool {
        return self.delegate?.tabBarController?(self, shouldSelect: index) ?? true
    }
    
    internal func tabBar(_ tabBar: PLTabBar, didSelect index: Int) {
        self.setSelectedIndex(index)
        self.delegate?.tabBarController?(self, didSelect: index)
    }
    
    internal func tabBar(_ tabBar: PLTabBar, didDoubleTap index: Int) {
        self.delegate?.tabBarController?(self, didDoubleTap: index)
    }
}


extension PL where Base: UIViewController {
    var tabBarController: PLTabBarController? {
        var parent = self.base.parent
        while parent != nil && !(parent is PLTabBarController) {
            parent = parent?.parent
        }
        return parent as? PLTabBarController

    }
}
