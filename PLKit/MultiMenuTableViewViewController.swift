//
//  MultiMenuTableViewViewController.swift
//  PLKit
//
//  Created by iOS on 2020/3/12.
//  Copyright © 2020 iOS. All rights reserved.
//

import UIKit

class MultiMenuTableViewViewController: UIViewController {

    @IBOutlet weak var tableView: PLMultimenuTableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}


extension MultiMenuTableViewViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = "row-\(indexPath.row)"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}

extension MultiMenuTableViewViewController: PLMultimenuDatasource {
    func tableView(_ tableView: UITableView, menuActionsForRowAt indexPath: IndexPath) -> [PLMultimenuAction] {
        
        let label = UILabel()
        label.text = "删除"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 18)
        label.sizeToFit()
        return [.init(view: label, handler: { (action, indexPath) in
            print("action")
        })]
    }
}
