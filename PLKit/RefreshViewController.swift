//
//  RefreshViewController.swift
//  PLKit
//
//  Created by iOS on 2019/4/26.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class RefreshViewController: UIViewController {

    var page = 1
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.pl.refresh.top = PLRefreshNormalHeader.init(callback: {[weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self?.tableView.pl.refresh.endTopRefresing()
                self?.page = 1
                self?.tableView.reloadData()
                
            })
        })
        self.tableView.pl.refresh.top?.gradualAlpha = true
        
        self.tableView.pl.refresh.bottom = PLRefreshNormalFooter.init(callback: {[weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self?.tableView.pl.refresh.endBottomRefresing()
                self?.page += 1
                self?.tableView.reloadData()
                
            })
        })

        self.tableView.pl.refresh.bottom?.gradualAlpha = true
    }
    
    override func viewDidLayoutSubviews() {
        print(self.tableView.safeAreaInsets)
    }
    deinit {
        print("deinit")
    }
}


extension RefreshViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5 * self.page
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text = "\(indexPath.row)"
            
        return cell!
    }
    
    
}
