//
//  PLNavigationController.swift
//  PLKit
//
//  Created by iOS on 2020/5/8.
//  Copyright © 2020 iOS. All rights reserved.
//

import UIKit



// MARK: - Class PLNavigationController
class PLNavigationController: UINavigationController {
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: ContainerController.init(content: rootViewController))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setViewControllers(self.viewControllers, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarHidden(true, animated: false)
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers.map({ ContainerController.init(content: $0) }), animated: animated)
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        let container = ContainerController.init(content: viewController)
        if let vc = self.topViewController as? ContainerController {
            container.warpNavigationBar.navigationBar.pushItem(vc.content.navigationItem, animated: false)
        } else {
            container.warpNavigationBar.navigationBar.pushItem(viewController.navigationItem, animated: false)
        }
        
        super.pushViewController(container, animated: animated)
    }
}


extension PLNavigationController {
    
    // MARK: - WarpNavigationBar
    class WarpNavigationBar: UIView {
        var navigationBar: UINavigationBar!
        
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
    
    // MARK: - Class ContainerController
    class ContainerController: UIViewController {
        
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
//            self.navigationItem.backBarButtonItem = .init(title: "Exit5", style: .plain, target: self, action: #selector(backBarButtonItemClick(_:)))
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            let statusBarFrame = UIApplication.shared.statusBarFrame
            
//            self.navigationItem.leftItemsSupplementBackButton = true
            self.navigationItem.leftBarButtonItem = .init(title: "Exit", style: .plain, target: self, action: #selector(backBarButtonItemClick(_:)))
            self.warpNavigationBar.navigationBar.pushItem(self.navigationItem, animated: false)
            self.warpNavigationBar.frame = .init(x: 0, y: 0, width: self.view.frame.width, height: 44 + statusBarFrame.height)
            
            if #available(iOS 11.0, *) {
                self.additionalSafeAreaInsets = .init(top: 44, left: 0, bottom: 0, right: 0)
            } else {
                // Fallback on earlier versions
            }
            
            self.view.addSubview(self.content.view)
            self.view.addSubview(self.warpNavigationBar)
        }
        
        override var navigationItem: UINavigationItem {
            return self.content.navigationItem
        }
        
        @objc fileprivate func backBarButtonItemClick(_ sender: UIBarButtonItem) {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
