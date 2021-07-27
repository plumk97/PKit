//
//  GridViewController.swift
//  PLKit
//
//  Created by Plumk on 2020/11/21.
//  Copyright © 2020 Plumk. All rights reserved.
//

import UIKit

class GridViewController: UIViewController {

    @IBOutlet weak var stackView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let gridView = PLGridView.init([Int](repeating: 0, count: 10).map({ _ in
            let view = UIView()
            view.backgroundColor = .random
            return view
        }))
        gridView.tag = 11
        gridView.crossAxisCount = 4
        gridView.mainAxisSpacing = 10
        gridView.crossAxisSpacing = 5
        stackView.addArrangedSubview(gridView)
        stackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options:[], metrics: nil, views: ["view": gridView]))
        
        
        let gridView1 = PLGridView.init([Int](repeating: 0, count: 10).map({ _ in
            let view = UIView()
            view.backgroundColor = .random
            return view
        }), axis: .vertical)
        gridView1.crossAxisCount = 4
        gridView1.mainAxisSpacing = 10
        gridView1.crossAxisSpacing = 5
//        gridView1.frame = .init(x: 15, y: 400, width: 0, height: 300)
        
//        gridView1.sizeToFit()
        self.view.addSubview(gridView1)
        gridView1.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[view]", options: [], metrics: nil, views: ["view": gridView1]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-400-[view(300)]", options: [], metrics: nil, views: ["view": gridView1]))
    }
}

extension UIColor {
    
    static var random: UIColor {
        return UIColor.init(red: CGFloat(arc4random() % 255) / 255.0,
                            green: CGFloat(arc4random() % 255) / 255.0,
                            blue: CGFloat(arc4random() % 255) / 255.0,
                            alpha: 1)
    }
}
