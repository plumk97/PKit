//
//  main.swift
//  Example-Command
//
//  Created by Plumk on 2022/6/2.
//  Copyright © 2022 Plumk. All rights reserved.
//

import Foundation
import PKit

enum AnimalType: String, PKJsonEnum {
    case cat = "cat"
    case dog = "dog"
    case bird = "bird"
}

struct Job: PKJson {
    @JsonKey var name = ""
    @JsonKey var salary = 0 {
        didSet {
            PKLog.log("new value")
        }
    }
}

struct Person: PKJson {
    
    @JsonKey var name = ""
    @JsonKey var age: Int?
    @JsonKey var tags = Set<Int>()
    @JsonKey var job = Job()
    @JsonKey var pet: [AnimalType?] = [.cat]
}

let json = """
{
    "name": "张三",
    "age": "18",
    "tags": ["1", "2", "3"],
    "pet": ["dog"],
    "job": {
        "name": "工人",
        "salary": 10000
    }
}
"""


let person = Person()

person.update(from: json)
//print(person.name, person.age, person.tags, person.pet)
print(person)
if let jsonStr = person.toJsonString() {
    print(jsonStr)
}
RunLoop.main.run()
