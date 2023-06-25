//
//  PKDateTransform.swift
//
//  Created by Plumk on 2022/6/2.
//

import Foundation

protocol PKDateTransform: _PKJsonTransformable,  PKJsonTransformable { }

extension PKDateTransform {
    static func _transform(from object: Any) -> Date? {
        
        switch object {
        case let str as String:
            
            let formatter = ISO8601DateFormatter()
            guard let date = formatter.date(from: str) else {
                return nil
            }
            
            return date
            
        case let num as NSNumber:
            return .init(timeIntervalSince1970: num.doubleValue)
            
        default:
            return nil
        }
    }
    
    func _plainValue() -> Any? {
        return ISO8601DateFormatter().string(from: self as! Date)
    }
}

extension Date: PKDateTransform {}
