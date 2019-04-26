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

        // Do any additional setup after loading the view.
        self.tableView.pl.refresh.top = PLRefreshNormalHeader.init(callback: {
            print("x")
        })
        print(self.tableView.pl.refresh.scrollView)
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
