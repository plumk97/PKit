//
//  JsonViewController.swift
//  PLKit
//
//  Created by mini2019 on 2020/10/12.
//  Copyright © 2020 iOS. All rights reserved.
//

import UIKit

class Test: NSObject, PLJSON {
    struct Detail: PLJSON {
        @JSONKey var city: String?
    }
    
    @JSONKey @objc dynamic var age: Int = 0
    @JSONKey var name: String?
    @JSONKey var detail: Detail?
    
    required override init() {
        super.init()
    }
}

class JsonViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    

    @IBAction func deserializeBtnClick(_ sender: UIButton) {
        let t = Test.deserialize(from: ["age": 25, "name": "Anx", "detail": ["city": "shenzhen"]])
        t.addObserver(self, forKeyPath: "age", options: .new, context: nil)
        t.age = 10
        print(t.age, t.name ?? "", t.detail?.city ?? "")
        
        let t1 = Test.deserialize(from: ["age": 22])
        print(t1.age, t1.name ?? "")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        (object as? Test)?.removeObserver(self, forKeyPath: "age")
    }
    
}
