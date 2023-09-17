//
//  DotViewController.swift
//  PKit
//
//  Created by Plumk on 2019/8/13.
//  Copyright © 2019 Plumk. All rights reserved.
//

import UIKit
import PKit

class DotViewController: UIViewController {

    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.btn1.pk.dot.position = .leftTop
        self.btn1.pk.dot.image = UIImage.init(named: "icon_dot")
        self.btn1.pk.dot.isHidden = false
        
        self.btn2.layer.pk.dot.isHidden = false
        
        self.navigationItem.rightBarButtonItem = .init(title: "AAA", style: .plain, target: nil, action: nil)
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem?.pk.dot?.isHidden = false
        }
    }
    
}
