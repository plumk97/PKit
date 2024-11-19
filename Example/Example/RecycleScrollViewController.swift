//
//  RecycleScrollViewController.swift
//  Example
//
//  Created by Plumk on 2023/12/11.
//  Copyright © 2023 Plumk. All rights reserved.
//

import UIKit
import PKit

class RecycleScrollViewController: UIViewController {

    let scrollView = PKUIRecycleScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pk.navigationConfig?.isTranslucent = false
        
        
        var views = [UIView]()
        for i in 0 ..< 5 {
            let label = UILabel()
            label.text = "\(i)"
            label.textColor = .white
            label.font = .systemFont(ofSize: 50)
            
            let view = UIView()
            view.backgroundColor = .black
            view.addSubview(label)
            label.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            views.append(view)
        }
        
        
        scrollView.views = views
        self.view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.left.top.width.equalToSuperview()
            make.height.equalTo(100)
        }
        
    }

    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
//        self.scrollView.setIndex(4, animated: true)
    }
}
