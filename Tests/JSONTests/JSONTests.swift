//
//  JSONTests.swift
//
//
//  Created by Plumk on 2022/5/25.
//

import XCTest
#if canImport(RxRelay)
import RxSwift
import RxRelay
#endif
@testable import PKJSON


let json = """
{
"name": "张三",
"date": "2023-07-28T16:06:26+08:00",
"job": {
    "name": "工人",
    "salary": 10000.5
    }
}
"""




final class JSONTests: XCTestCase {
    
    func testCoding() throws {
    
        struct Job: PKJson {
            
            @JsonKey var name = ""
            @JsonKey var salary: Double = 0 {
                didSet {
                    print("new value")
                }
            }
        }

        struct Person: PKJson {
            
        #if canImport(RxRelay)
            @JsonKey
            var name: BehaviorRelay<String> = .init(value: "")
        #else
            @JsonKey
            var name: String = ""
        #endif
            
            @JsonKey
            var date = Date()
            
            @JsonKey var job = Job()
        }
        
        
        let person = Person()
#if canImport(RxRelay)
        let disposeBag = DisposeBag()
        person.name.subscribe { name in
            print(name)
        }.disposed(by: disposeBag)
#endif
        person.update(from: json)
        print(person)
    }
    
}
