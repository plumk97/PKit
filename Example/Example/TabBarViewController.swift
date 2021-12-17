//
//  TabBarViewController.swift
//  PKit
//
//  Created by Plumk on 2019/8/7.
//  Copyright © 2019 Plumk. All rights reserved.
//

import UIKit
import PKit

class TabBarViewController: PKUITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc1 = TestViewController()
        let vc2 = TestViewController()
        let vc3 = TestViewController()
        let vc4 = TestViewController()
        
        vc1.pk.tabBarItem.style.title = "首页"
        vc1.pk.tabBarItem.style.image = UIImage.init(named: "tabbar_home")
        vc1.pk.tabBarItem.style.selectedImage = UIImage.init(named: "tabbar_home_selected")
        vc1.pk.tabBarItem.badgeView.string = "12"
        
        vc2.pk.tabBarItem.style.title = "消息"
        vc2.pk.tabBarItem.style.image = UIImage.init(named: "tabbar_message")
        vc2.pk.tabBarItem.style.selectedImage = UIImage.init(named: "tabbar_message_selected")
        vc2.pk.tabBarItem.badgeView.string = "12"
        
        
        vc3.pk.tabBarItem.style.title = "CP空间"
        vc3.pk.tabBarItem.style.image = UIImage.init(named: "tabbar_space")
        vc3.pk.tabBarItem.style.selectedImage = UIImage.init(named: "tabbar_space_selected")
        
        vc4.pk.tabBarItem.style.title = "我的"
        vc4.pk.tabBarItem.style.image = UIImage.init(named: "tabbar_mine")
        vc4.pk.tabBarItem.style.selectedImages = [Int](1 ... 15).map({ UIImage.init(named: "tabbar_mine_selected\($0)")!})
        
        self.setSelectedIndex(2, animation: false)
        self.viewControllers = [vc1, vc2, vc3, vc4]
        
    }
    
}

extension TabBarViewController {
    
    class TestViewController: UIViewController {
        override func viewDidLoad() {
            super.viewDidLoad()
            print("view", self.pk.tabBarController)
            view.backgroundColor = .init(red: CGFloat(arc4random_uniform(255)) / 255.0, green: CGFloat(arc4random_uniform(255)) / 255.0, blue: CGFloat(arc4random_uniform(255)) / 255.0, alpha: 1)
        }
    }
}
