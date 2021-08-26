//
//  HUDViewController.swift
//  PKit
//
//  Created by Plumk on 2019/8/10.
//  Copyright © 2019 Plumk. All rights reserved.
//

import UIKit
import PKit

class HUDViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnClick(_ sender: Any) {
//        PLHUD.init(text: "明天（10日）出版的《人民日报》将发表署名文章——《世界应当共同抵制偏执极端之祸》").show()
        
        let text = NSMutableAttributedString.init(string: "明天（10日）出版的《人民日报》将发表署名文章——《世界应当共同抵制偏执极端之祸》", attributes: [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.white
        ])
        
        text.addAttributes([.foregroundColor: UIColor.red], range: .init(location: 10, length: 6))
        PLHUD.init(text).show()
    }
    
}
