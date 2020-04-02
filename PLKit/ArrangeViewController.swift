//
//  ArrangeViewController.swift
//  PLKit
//
//  Created by iOS on 2020/4/2.
//  Copyright © 2020 iOS. All rights reserved.
//

import UIKit

class ArrangeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.load1()
        self.load2()
        
    }

    func load1() {
        let view1 = UIView.init(frame: .init(x: 0, y: 0, width: 50, height: 100))
        view1.backgroundColor = .red
        
        let view2 = UIView.init(frame: .init(x: 0, y: 0, width: 100, height: 50))
        view2.backgroundColor = .blue
        
        let arrangeView = PLArrangeView.init(views: [view1, view2])
        arrangeView.frame.origin = .init(x: 20, y: 100)
        arrangeView.alignment = .bottom
        arrangeView.direction = .vertical
        arrangeView.layoutIfNeeded()
        arrangeView.sizeToFit()
        self.view.addSubview(arrangeView)
    }
    
    func load2() {
        let view1 = UIView.init(frame: .init(x: 0, y: 0, width: 50, height: 100))
        view1.backgroundColor = .red
        
        let view2 = UIView.init(frame: .init(x: 0, y: 0, width: 100, height: 50))
        view2.backgroundColor = .blue
        
        let arrangeView = PLArrangeView.init(views: [view1, view2])
        arrangeView.frame.origin = .init(x: 20, y: 400)
        arrangeView.sizeToFit()
        self.view.addSubview(arrangeView)
    }
}
