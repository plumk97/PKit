//
//  JSONTests.swift
//  
//
//  Created by Plumk on 2022/5/25.
//

import XCTest
@testable import PKCore
@testable import PKJSON


struct Job: PKJson {
    
    @JsonKey var name = ""
    @JsonKey var salary: Double = 0 {
        didSet {
            PKLog.log("new value")
        }
    }
}

class Person: NSObject, PKJson {
    
    @JsonKey @objc dynamic var name = ""
    @JsonKey
    var date = Date()
    
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
    "date": "2023-07-28T16:06:26+08:00",
    "job": {
        "name": "工人",
        "salary": "10000.5"
    }
}
"""
        
        //2023-06-25T14:06:00.237+08:00
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFullDate, .withTime, .withFractionalSeconds]
        print(formatter.date(from: "2023-07-28T16:06:26.444+08:00"))
        let person = Person.decode(json)
        print(person.toJson())
        
        let person1 = Person.decode(json)
        print(person1.toJson())
    }
}
