//
//  NavigationController.swift
//  PLKit
//
//  Created by iOS on 2020/5/8.
//  Copyright © 2020 iOS. All rights reserved.
//

import UIKit

class NavigationController: UIViewController {

    var isHideNavigationBar: Bool = false
    var isTransitionNavigationBar: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "vc \(self.navigationController?.viewControllers.count ?? 0)"
        
        if self.isHideNavigationBar {
            self.pl.navigationBar?.isHidden = true
        }
        
        
        if self.isTransitionNavigationBar {
            self.pl.navigationBar?.backgroundColor = .orange
            
            let scrollView = UIScrollView.init(frame: self.view.bounds)
            scrollView.backgroundColor = .white
            scrollView.delegate = self
            scrollView.contentSize = .init(width: 0, height: 999)
            self.view.addSubview(scrollView)
            self.view.sendSubviewToBack(scrollView)
        }
        
    }
    
    @IBAction func push(_ sender: Any) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "NavigationController") else {
            return
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func pushAndRemove(_ sender: Any) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "NavigationController") else {
            return
        }
        self.pl.navigationController?.pushViewController(vc, animated: true, complete: {
            self.pl.navigationController?.removeViewController(self)
        })
    }
    
    @IBAction func pushAndHideNavigationBar(_ sender: Any) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "NavigationController") as? NavigationController else {
            return
        }
        vc.isHideNavigationBar = true
        self.pl.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func pushAndTransitionBar(_ sender: Any) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "NavigationController") as? NavigationController else {
            return
        }
        vc.isTransitionNavigationBar = true
        self.pl.navigationController?.pushViewController(vc, animated: true)
    }
}

extension NavigationController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard let navigationBar = self.pl.navigationBar else {
            return
        }
        let alpha = scrollView.contentOffset.y / navigationBar.frame.height
        navigationBar.backgroundColor = UIColor.orange.withAlphaComponent(alpha)
    }
}
