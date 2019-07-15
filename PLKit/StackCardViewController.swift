//
//  StackCardViewController.swift
//  PLKit
//
//  Created by iOS on 2019/7/15.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class StackCardViewController: UIViewController {
    
    var stackCardView: PLStackCardView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.stackCardView = PLStackCardView.init(contentSize: .init(width: 331, height: 490))
        self.stackCardView.frame.origin = .init(x: (view.bounds.width - 331) / 2, y: 100)
        self.view.addSubview(self.stackCardView)
        
        
        var views = [UIView]()
        for _ in 0 ..< 10 {
            let view = UIView.init(frame: .init(x: 0, y: 0, width: 331, height: 490))
            view.backgroundColor = .init(red: CGFloat(arc4random_uniform(255)) / 255.0, green: CGFloat(arc4random_uniform(255)) / 255.0, blue: CGFloat(arc4random_uniform(255)) / 255.0, alpha: 1)
            views.append(view)
        }
        
        self.stackCardView.cardViews = views
        self.stackCardView.reloadData()
    }
}
