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

    var badgeView: PKUIBadgeView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        badgeView = PKUIBadgeView()
        badgeView.frame.origin = .init(x: 20, y: 100)
        self.view.addSubview(badgeView)
        
    }
    
    var count = 0
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        count += 1
        badgeView.string = "\(count)"
        badgeView.sizeToFit()
    }
}
