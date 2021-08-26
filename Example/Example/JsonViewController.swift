//
//  JsonViewController.swift
//  PKit
//
//  Created by Plumk on 2020/10/12.
//  Copyright © 2020 Plumk. All rights reserved.
//

import UIKit
import PKit

class Test: NSObject, PLJSON {
    struct Detail: PLJSON {
        @JSON var city: String?
    }
    
    @JSON @objc dynamic var age: Int = 0
    @JSON var name: String?
    @JSON var names: [String]?
    
    @JSON(type: Detail.self) var detail: Detail? = nil
    @JSON(type: Detail.self) var details: [Detail]? = nil
    
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
        let t = Test.deserialize(from: ["age": 25,
                                        "name": "Anx",
                                        "names": ["a", "b"],
                                        "detail": ["city": "shenzhen"],
                                        "details": [["city": "shenzhen1"], ["city": "shenzhen2"], ["city": "shenzhen3"]]])
        
        t.addObserver(self, forKeyPath: "age", options: .new, context: nil)
        t.age = 10
        print(t.age, t.name ?? "", t.names, t.detail?.city, t.details?.map({ $0.city }))
        
        let t1 = Test.deserialize(from: ["age": 22])
        print(t1.age, t1.name ?? "")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        (object as? Test)?.removeObserver(self, forKeyPath: "age")
        print(change!)
    }
    
}
