//
//  TabControlViewController.swift
//  PLKit
//
//  Created by Plumk on 2020/4/9.
//  Copyright © 2020 Plumk. All rights reserved.
//

import UIKit

class TabControlViewController: UIViewController {
    
    
    var tabControl: PLTabControl!
    
    var scrollView: UIScrollView!
    var scrollViewBeginPoint: CGPoint = .zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.scrollView = UIScrollView.init(frame: self.view.bounds)
        self.scrollView.delegate = self
        self.view.addSubview(self.scrollView)
        
        let view1 = UIView.init(frame: self.view.bounds)
        view1.backgroundColor = .black
        self.scrollView.addSubview(view1)
        
        let view2 = UIView.init(frame: self.view.bounds.offsetBy(dx: self.view.bounds.width * 1, dy: 0))
        view2.backgroundColor = .orange
        self.scrollView.addSubview(view2)
        
        let view3 = UIView.init(frame: self.view.bounds.offsetBy(dx: self.view.bounds.width * 2, dy: 0))
        view3.backgroundColor = .white
        self.scrollView.addSubview(view3)
        
        self.scrollView.contentSize = .init(width: view3.frame.maxX, height: 0)
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.bounces = false
        self.scrollView.isPagingEnabled = true
        
        
        let item1 = PLTabControl.Item.init(title: "个人主页", color: .init(red: 1, green: 1, blue: 1, alpha: 0.8), selectedColor: .white)
        let item2 = PLTabControl.Item.init(title: "个人中心", color: .black, selectedColor: .white)
        let item3 = PLTabControl.Item.init(title: "CP空间", color: .init(red: 0, green: 0, blue: 0, alpha: 0.8), selectedColor: .black)
        
        
        self.tabControl = PLTabControl.init(items: [item1, item2, item3])
        self.tabControl.indicateHeight = 5
        self.tabControl.sizeToFit()
        self.tabControl.frame.origin = .init(x: 30, y: 100)
        self.view.addSubview(self.tabControl)
        
        self.tabControl.indicateColors = [.cyan, .red]
        
        self.tabControl.didChangeSelectedIndexBlock = { index in
            
            let offset = CGPoint.init(x: self.scrollView.frame.width * CGFloat(index), y: 0)
            self.scrollView.setContentOffset(offset, animated: true)
        }
    }
}


extension TabControlViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.tabControl.scrollViewWillBeginDragging(scrollView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.tabControl.scrollViewDidScroll(scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.tabControl.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
}
