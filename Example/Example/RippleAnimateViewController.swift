//
//  RippleAnimateViewController.swift
//  PKit
//
//  Created by Plumk on 2019/4/23.
//  Copyright © 2019 Plumk. All rights reserved.
//

import UIKit
import PKit

class RippleAnimateViewController: UIViewController {

    
    var rippleAnimate: PKUIRippleAnimate!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        let rippleView = UIView.init(frame: .init(x: 50, y: 200, width: 50, height: 50))
        rippleView.layer.cornerRadius = 50 / 2
        rippleView.backgroundColor = .red
        self.view.addSubview(rippleView)
        
        rippleView.pk.rippleAnimate.fromScale = 0.8
        rippleView.pk.rippleAnimate.toScale = 1.5
        rippleView.pk.rippleAnimate.startAnimation()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            rippleView.pl.rippleAnimate.animateNumber = 2
//        }
    }
}

