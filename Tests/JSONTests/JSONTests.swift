//
//  JSONTests.swift
//  
//
//  Created by Plumk on 2022/5/25.
//

import XCTest
@testable import PKCore


struct Job: PKJson {
    
    @JsonKey var name = ""
    @JsonKey var salary = 0 {
        didSet {
            PKLog.log("new value")
        }
    }
}

class Person: NSObject, PKJson {
    
    @JsonKey @objc dynamic var name = ""
    @JsonKey var job = Job()
    
    required override init() {
        super.init()
    }
}




final class JSONTests: XCTestCase {
    
    func testDecode() throws {
        
        let json = """
{
    "name": "张三",
    "job": {
        "name": "工人",
        "salary": 10000
    }
}
"""
        
        let person = Person.decode(json)
        print(person)
    }
}
