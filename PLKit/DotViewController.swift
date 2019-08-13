//
//  DotViewController.swift
//  PLKit
//
//  Created by iOS on 2019/8/13.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class DotViewController: UIViewController {

    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.btn1.pl.dot.position = .leftTop
        self.btn1.pl.dot.image = UIImage.init(named: "icon_dot")
        self.btn1.pl.dot.isHidden = false
        
        self.btn2.pl.dot.isHidden = false
    }
    
}
