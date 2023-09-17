//
//  BadgeViewViewController.swift
//  PKit
//
//  Created by Plumk on 2019/6/9.
//  Copyright © 2019 Plumk. All rights reserved.
//

import UIKit
import PKit

class BadgeViewViewController: UIViewController {

    let attachView = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.attachView.backgroundColor = .black
        self.attachView.frame = .init(origin: .init(x: 20, y: 100), size: .init(width: 100, height: 100))
        self.view.addSubview(self.attachView)
    
        self.attachView.pk.badge.string = "123"
        
        self.navigationItem.rightBarButtonItem = .init(title: "AAA", style: .plain, target: nil, action: nil)
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem?.pk.badge?.string = "33"
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        self.attachView.pk.badge.string = "\(Int.random(in: 1 ..< 999))"
        self.attachView.frame.size = .init(width: .random(in: 100 ..< 200), height: .random(in: 100 ..< 200))
    }
//    var count = 0
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        count += 1
//        badgeView.string = "\(count)"
//        badgeView.sizeToFit()
//    }
}
