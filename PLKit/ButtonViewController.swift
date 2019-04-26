//
//  ButtonViewController.swift
//  PLKit
//
//  Created by iOS on 2019/4/26.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class ButtonViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn = PLButton()
        btn.title = "123123123"
        btn.rightIcon.image = UIImage.init(named: "arrow_bottom_small")
        btn.leftIcon.image = UIImage.init(named: "arrow_bottom_small")
        btn.topIcon.image = UIImage.init(named: "arrow_bottom_small")
        btn.bottomIcon.image = UIImage.init(named: "arrow_bottom_small")
        btn.spaceingEdge = .init(top: 10, left: 20, bottom: 10, right: 0)
        btn.spaceingTitleImage = 10
        btn.pointBoundsInset = .init(top: -10, left: -10, bottom: -10, right: -10)
        btn.sizeToFit()
        btn.frame.origin = .init(x: 20, y: 100)
        btn.borderColor = UIColor.blue
        btn.borderWidth = 1
        btn.cornerRadius = 10
        self.view.addSubview(btn)
        
        btn.addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside)
    }
    
    @objc func btnClick(_ sender: PLButton) {
    }
}
