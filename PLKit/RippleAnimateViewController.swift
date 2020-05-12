//
//  RippleAnimateViewController.swift
//  PLKit
//
//  Created by iOS on 2019/4/23.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class RippleAnimateViewController: UIViewController {

    
    var rippleAnimate: PLRippleAnimate!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        let rippleView = UIView.init(frame: .init(x: 50, y: 200, width: 50, height: 50))
        rippleView.layer.cornerRadius = 50 / 2
        rippleView.backgroundColor = .red
        self.view.addSubview(rippleView)
        
        rippleView.pl.rippleAnimate.fromScale = 0.8
        rippleView.pl.rippleAnimate.toScale = 1.5
        rippleView.pl.rippleAnimate.startAnimation()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            rippleView.pl.rippleAnimate.animateNumber = 2
//        }
    }
}

