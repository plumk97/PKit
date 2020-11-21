//
//  TableViewController.swift
//  PLKit
//
//  Created by Plumk on 2020/5/9.
//  Copyright © 2020 Plumk. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if #available(iOS 11, *) {
            self.tableView.contentInset.top = self.pl.navigationBar!.frame.height
            self.tableView.contentInset.bottom = self.view.safeAreaInsets.bottom
        } else {
            self.tableView.contentInset.top = self.pl.navigationBar!.frame.height
        }
        self.tableView.scrollIndicatorInsets.top = self.tableView.contentInset.top
    }

}
