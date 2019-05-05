//
//  PageScrollViewController.swift
//  PLKit
//
//  Created by iOS on 2019/4/30.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class PageScrollViewController: UIViewController {

    var pageScrollView: PLPageScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let headerView = UIView.init(frame: .init(x: 0, y: 0, width: self.view.frame.width, height: 200))
        headerView.backgroundColor = .blue
        
        let tableView1 = UITableView.init(frame: .zero)
        tableView1.tag = 1
        tableView1.dataSource = self
        
        let tableView2 = UITableView.init(frame: .zero)
        tableView2.tag = 2
        tableView2.dataSource = self
        
        let tableView3 = UITableView.init(frame: .zero)
        tableView3.tag = 3
        tableView3.dataSource = self
        
        self.pageScrollView = PLPageScrollView.init(frame: self.view.bounds)
        self.pageScrollView.contentInsetAdjustmentBehavior = .never
        self.pageScrollView.headerView = headerView
        self.pageScrollView.contentScrollViews = [tableView1, tableView2, tableView3]
        self.view.addSubview(self.pageScrollView)

        self.pageScrollView.pl.refresh.top = PLRefreshNormalHeader.init(callback: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.pageScrollView.pl.refresh.endTopRefresing()
            })
        })
        self.pageScrollView.pl.refresh.top?.gradualAlpha = true
        
        tableView1.pl.refresh.bottom = PLRefreshNormalFooter.init(callback: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                tableView1.pl.refresh.endBottomRefresing()
            })
        })
        tableView1.pl.refresh.bottom?.gradualAlpha = true
        
    }
}

extension PageScrollViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = "\(tableView.tag)--\(indexPath.row)"
        
        return cell!
    }
}
