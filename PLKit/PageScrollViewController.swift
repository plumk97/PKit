//
//  PageScrollViewController.swift
//  PLKit
//
//  Created by iOS on 2019/4/30.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit
import MJRefresh

class PLTable: UITableView {
 
}
class PageScrollViewController: UIViewController {

    var pageScrollView: PLPageScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let headerView = UIView.init(frame: .init(x: 0, y: 0, width: self.view.frame.width, height: 200))
        headerView.backgroundColor = .blue
        
        let tableView1 = PLTable.init(frame: .zero)
        tableView1.tag = 1
        tableView1.dataSource = self
        tableView1.delegate = self
        
        let tableView2 = UITableView.init(frame: .zero)
        tableView2.tag = 2
        tableView2.dataSource = self
        
        let tableView3 = UITableView.init(frame: .zero)
        tableView3.tag = 3
        tableView3.dataSource = self
        
        let bottom = self.navigationController?.navigationBar.frame.maxY ?? 0
        
        self.pageScrollView = PLPageScrollView.init(frame: .init(x: 0, y: bottom, width: self.view.bounds.width, height: self.view.bounds.height - bottom))
        if #available(iOS 11.0, *) {
            self.pageScrollView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        self.pageScrollView.headerView = headerView
        self.pageScrollView.contentScrollViews = [tableView1, tableView2, tableView3]
        self.view.addSubview(self.pageScrollView)

        self.pageScrollView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {[unowned self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.pageScrollView.mj_header?.endRefreshing()
            })
        })
        
        tableView1.mj_footer = MJRefreshBackNormalFooter.init(refreshingBlock: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                tableView1.mj_footer?.endRefreshing()
            })
        })
        
    }
}

extension PageScrollViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = "\(tableView.tag)--\(indexPath.row)"
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(tableView.pl_pageScrollView)
    }
}
