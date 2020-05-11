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
        super.init(rootViewController: ContainerController.init(content: rootViewController))
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
    func removeViewController(_ viewController: UIViewController) -> UIViewController?  {
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
        
        var content: UIViewController!
        var warpNavigationBar: WarpNavigationBar!
        
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
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            if self != self.navigationController?.viewControllers.first {
                
                // -- back item
                self.navigationItem.leftItemsSupplementBackButton = true
                
                let backImage = UIImage.init(named: "nav_back")?.withRenderingMode(.alwaysOriginal)
                
                let backButton = UIButton(type: .system)
                backButton.setImage(backImage, for: .normal)
                backButton.frame.size = .init(width: (backImage?.size.width ?? 0) + 19, height: 44)
                backButton.addTarget(self, action: #selector(backBarButtonItemClick(_:)), for: .touchUpInside)
                
                
                // 直接使用 .init(image: ) 在 iOS11以上 与 iOS11以下 表现不一样
                self.navigationItem.leftBarButtonItem = .init(customView: backButton)
            }
            
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
        
        @objc fileprivate func backBarButtonItemClick(_ sender: UIButton) {
            self.navigationController?.popViewController(animated: true)
        }
        
        // MARK: - UIGestureRecognizerDelegate
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer
        }
    }
}


extension PLNavigationController {
    // MARK: - Class WarpNavigationBar
    class WarpNavigationBar: UIView {
        
        class _NavigationBar: UINavigationBar {
            
            // leftBarButtonItems 与边缘边距
            var leftTrailing: CGFloat = 0
            // rightBarButtonItems 与边缘边距
            var rightTrailing: CGFloat = -8
            
            fileprivate weak var leftTrailingConstraint: NSLayoutConstraint?
            fileprivate weak var rightTrailingConstraint: NSLayoutConstraint?
            
            override func layoutSubviews() {
                super.layoutSubviews()
                
                if #available(iOS 11.0, *) {
                    
                    if self.leftTrailingConstraint == nil || self.rightTrailingConstraint == nil {
                        self.subviews.forEach({
                            if type(of: $0).description() == "_UINavigationBarContentView" {
                                $0.constraints.forEach({[weak self] in
                                    if $0.firstAttribute == .trailing {
                                        if $0.constant > 0 {
                                            self?.leftTrailingConstraint = $0
                                        } else {
                                            self?.rightTrailingConstraint = $0
                                        }
                                    }
                                })
                            }
                        })
                    }
                    
                    self.leftTrailingConstraint?.constant = self.leftTrailing
                    // 加上8等于 right == self.bounds.width 再计算
                    self.rightTrailingConstraint?.constant = 8 + self.rightTrailing
                    
                } else {
                    
                    self.relayoutSubviews()
                }
            }
            
            
            /// iOS 11以下的使用的frame布局 重新计算frame
            fileprivate func relayoutSubviews() {
                guard let item = self.topItem else {
                    return
                }
                
                // -- leftBarButtonItems
                // 与iOS 11以上的保持一致
                var left: CGFloat = self.leftTrailing
                if let leftBarButtonItems = item.leftBarButtonItems {
                    for buttonItem in leftBarButtonItems {
                        guard let view = buttonItem.value(forKey: "view") as? UIView else {
                            return
                        }
                        
                        view.frame.origin.x = left
                        left = view.frame.maxX + 8
                    }
                }
                
                // -- rightBarButtonItems
                // 与iOS 11以上的保持一致 iOS11以上的BarButtonItem内部留有8间距
                var right: CGFloat = self.bounds.width - 8 + self.rightTrailing
                if let rightBarButtonItems = item.rightBarButtonItems {
                    for buttonItem in rightBarButtonItems {
                        guard let view = buttonItem.value(forKey: "view") as? UIView else {
                            return
                        }
                        
                        view.frame.origin.x = right - view.frame.width
                        
                        right = view.frame.minX - 8
                    }
                }
                
                // -- UINavigationItemView
                let itemView = self.subviews.first(where: {
                    type(of: $0).description() == "UINavigationItemView"
                })
                if let itemView = itemView {
                    
                    var frame = itemView.frame
                    frame.origin.x = (self.bounds.width - frame.width) / 2
                    
                    if frame.minX < left || frame.maxX > right {
                        let remainWidth = right - left
                        frame.size.width = min(remainWidth, frame.size.width)
                        frame.origin.x = (remainWidth - frame.width) / 2 + left
                    }
                    
                    itemView.frame = frame
                }
                
            }
        }
        
        
        private(set) var navigationBar: _NavigationBar!
        
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
            
            self.navigationBar = _NavigationBar()
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
        return nil
    }
}
