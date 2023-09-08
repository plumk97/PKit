//
//  ButtonViewController.swift
//  PKit
//
//  Created by Plumk on 2019/4/26.
//  Copyright © 2019 Plumk. All rights reserved.
//

import UIKit
import PKit

class ButtonViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.title = "Button \(self.navigationController?.viewControllers.count ?? 0)"
        
        let btn = PKUIButton()
        btn.title = "123123123"
        btn.setTitle("333", for: .highlighted)
        btn.rightIcon.image = UIImage.init(named: "arrow_bottom_small")
        btn.rightIcon.setImage(UIImage(), for: .highlighted)
        btn.leftIcon.image = UIImage.init(named: "arrow_bottom_small")
        btn.topIcon.image = UIImage.init(named: "arrow_bottom_small")
        btn.bottomIcon.image = UIImage.init(named: "arrow_bottom_small")
        btn.padding = .init(top: 10, left: 20, bottom: 10, right: 0)
        btn.spaceingTitleImage = 10
        btn.pointBoundsInset = .init(top: -10, left: -10, bottom: -10, right: -10)
        btn.sizeToFit()
        btn.frame.origin = .init(x: 20, y: 100)
        btn.borderColor = UIColor.blue
        btn.borderWidth = 1
        btn.cornerRadius = 10
        self.view.addSubview(btn)
        
        
        let pdata = try! Data.init(contentsOf: URL.init(string: "http://e.hiphotos.baidu.com/image/pic/item/4610b912c8fcc3cef70d70409845d688d53f20f7.jpg")!)
        if let image = UIImage.init(data: pdata) {
            btn.backgroundImage = image
        }
        
        
        btn.addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside)
    
        
    }
    
    
    @objc func btnClick(_ sender: PKUIButton) {
        
        let vc = ButtonViewController()
        if let nav = self.navigationController as? PKUINavigationController {
            nav.present(PKUINavigationController.init(rootViewController: vc), animated: true, completion: nil)
//            nav.pushViewController(vc, animated: true) {
//                nav.removeViewController(self)
//            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
