//
//  PKLog.swift
//  
//
//  Created by Plumk on 2021/12/17.
//

import Foundation

public class PKLog {
    
    private init() {
        
    }
    
    public static func log(_ items: Any..., iden: String = "[DEBUG]", file: String = #file, line: Int = #line) {
        var output = ""
        for item in items {
            
            var t = ""
            print(item, separator: "", terminator: "", to: &t)
            output += t + " "
            
        }
        print(iden + URL.init(fileURLWithPath: file).lastPathComponent + ":\(line) -> " + output)
    }
}
