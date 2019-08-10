//
//  HUDViewController.swift
//  PLKit
//
//  Created by iOS on 2019/8/10.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class HUDViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnClick(_ sender: Any) {
        PLHUD.init(text: "明天（10日）出版的《人民日报》将发表署名文章——《世界应当共同抵制偏执极端之祸》").show()
    }
    
}
