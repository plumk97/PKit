//
//  GridViewController.swift
//  PLKit
//
//  Created by Plumk on 2020/11/21.
//  Copyright © 2020 Plumk. All rights reserved.
//

import UIKit

class GridViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gridView = PLGridView.init([Int](repeating: 0, count: 10).map({ _ in
            let view = UIView()
            view.backgroundColor = .random
            return view
        }))
        gridView.crossAxisCount = 4
        gridView.mainAxisSpacing = 10
        gridView.crossAxisSpacing = 5
        gridView.frame = .init(x: 15, y: 100, width: self.view.frame.width - 30, height: 0)
        
        gridView.sizeToFit()
        self.view.addSubview(gridView)
        
        
        let gridView1 = PLGridView.init([Int](repeating: 0, count: 10).map({ _ in
            let view = UIView()
            view.backgroundColor = .random
            return view
        }), direction: .vertical)
        gridView1.crossAxisCount = 4
        gridView1.mainAxisSpacing = 10
        gridView1.crossAxisSpacing = 5
        gridView1.frame = .init(x: 15, y: gridView.frame.maxY + 50, width: 0, height: 300)
        
        gridView1.sizeToFit()
        self.view.addSubview(gridView1)
        
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
