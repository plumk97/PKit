//
//  PKStringError.swift
//
//  Created by Plumk on 2025/1/4.
//

import Foundation


public struct PKStringError: LocalizedError {
    
    let msg: String
    
    public init(msg: String) {
        self.msg = msg
    }
    
    public var errorDescription: String? {
        self.msg
    }
}
