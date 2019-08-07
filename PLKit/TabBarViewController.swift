//
//  TabBarViewController.swift
//  PLKit
//
//  Created by iOS on 2019/8/7.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class TabBarViewController: PLTabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc1 = TestViewController()
        let vc2 = TestViewController()
        let vc3 = TestViewController()
        let vc4 = TestViewController()
        
        vc1.pl.tabBarItem.style.title = "首页"
        vc1.pl.tabBarItem.style.image = UIImage.init(named: "tabbar_home")
        vc1.pl.tabBarItem.style.selectedImage = UIImage.init(named: "tabbar_home_selected")
        vc1.pl.tabBarItem.badgeView.string = "12"
        
        vc2.pl.tabBarItem.style.title = "消息"
        vc2.pl.tabBarItem.style.image = UIImage.init(named: "tabbar_message")
        vc2.pl.tabBarItem.style.selectedImage = UIImage.init(named: "tabbar_message_selected")
        vc2.pl.tabBarItem.badgeView.string = "12"
        
        
        vc3.pl.tabBarItem.style.title = "CP空间"
        vc3.pl.tabBarItem.style.image = UIImage.init(named: "tabbar_space")
        vc3.pl.tabBarItem.style.selectedImage = UIImage.init(named: "tabbar_space_selected")
        
        vc4.pl.tabBarItem.style.title = "我的"
        vc4.pl.tabBarItem.style.image = UIImage.init(named: "tabbar_mine")
        vc4.pl.tabBarItem.style.selectedImage = UIImage.init(named: "tabbar_mine_selected")
        
        self.viewControllers = [vc1, vc2, vc3, vc4]
    }
    
}

extension TabBarViewController {
    
    class TestViewController: UIViewController {
        override func viewDidLoad() {
            super.viewDidLoad()
            print("view", self)
            view.backgroundColor = .init(red: CGFloat(arc4random_uniform(255)) / 255.0, green: CGFloat(arc4random_uniform(255)) / 255.0, blue: CGFloat(arc4random_uniform(255)) / 255.0, alpha: 1)
        }
    }
}
