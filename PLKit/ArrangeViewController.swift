//
//  ArrangeViewController.swift
//  PLKit
//
//  Created by Plumk on 2020/4/2.
//  Copyright © 2020 Plumk. All rights reserved.
//

import UIKit

class ArrangeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.load1()
        self.load2()
        
    }

    func load1() {
        
        let tags = ["和谐", "和谐", "和谐", "和谐", "和谐", "和谐", "和谐", "和谐", "和谐", "和谐", "和谐", "和谐", "和谐", "和谐", "和谐"]
        
        let arrange = PLArrangeView.init(tags.map({
            let label = UILabel()
            label.text = $0
            label.backgroundColor = .red
            return label
        }), direction: .horizontal, mainAxisSpacing: 10, crossAxisSpacing: 10)
        self.view.addSubview(arrange)
        
        arrange.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-100-[view]", options: [], metrics: nil, views: ["view": arrange]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[view]-|", options: [], metrics: nil, views: ["view": arrange]))
        
    }
    
    func load2() {
        
        let tags = ["和谐", "和谐", "和谐", "和谐", "和谐", "和谐", "和谐", "和谐", "和谐", "和谐", "和谐", "和谐", "和谐", "和谐", "和谐"]
        
        let arrange = PLArrangeView.init(tags.map({
            let label = UILabel()
            label.text = $0
            label.backgroundColor = .red
            return label
        }), direction: .vertical, mainAxisSpacing: 10, crossAxisSpacing: 10)
        self.view.addSubview(arrange)

        arrange.frame.origin = .init(x: 15, y: 300)
        arrange.frame.size.height = 300
        arrange.sizeToFit()
    }
}
