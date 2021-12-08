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

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0
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
