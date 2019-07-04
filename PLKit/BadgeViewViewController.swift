//
//  BadgeViewViewController.swift
//  PLKit
//
//  Created by 李铁柱 on 2019/6/9.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class BadgeViewViewController: UIViewController {

    var badgeView: PLBadgeView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        badgeView = PLBadgeView()
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
