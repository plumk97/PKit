//
//  TableViewController.swift
//  PKit
//
//  Created by Plumk on 2020/5/9.
//  Copyright © 2020 Plumk. All rights reserved.
//

import UIKit
import PKit

class TableViewController: UITableViewController {

    var isHiddenStatusBar: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pk.navigationConfig?.isTranslucent = false
        
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0
        }
        
        self.navigationItem.rightBarButtonItem = .init(title: "Toggle StatusBar Hidden", style: .plain, target: self, action: #selector(toggleStatusBarHiddenItemClick))
    }
    
    @objc func toggleStatusBarHiddenItemClick() {
        self.isHiddenStatusBar = !self.isHiddenStatusBar
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override var prefersStatusBarHidden: Bool {
        return self.isHiddenStatusBar
    }
}
