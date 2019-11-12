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
        
        
        let layer = CAShapeLayer.init()
        layer.frame = .init(x: 30, y: 100, width: 200, height: 200)
        layer.backgroundColor = UIColor.black.cgColor
        layer.strokeColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.red.cgColor
        self.view.layer.addSublayer(layer)
        
        let path = UIBezierPath()
        path.addArc(withCenter: .init(x: 100, y: 100), radius: 100, startAngle: -90 * (CGFloat.pi / 180), endAngle: -45 * 0.01745, clockwise: true)
        layer.path = path.cgPath
        
        
    }
    
    @IBAction func btnClick(_ sender: Any) {
        PLHUD.init(text: "明天（10日）出版的《人民日报》将发表署名文章——《世界应当共同抵制偏执极端之祸》").show()
    }
    
}
