//
//  PKDateTransform.swift
//
//  Created by Plumk on 2022/6/2.
//

import Foundation

fileprivate let fsFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
}()

fileprivate let formatter = {
    let formatter = ISO8601DateFormatter()
    return formatter
}()

protocol PKDateTransform: _PKJsonTransformable,  PKJsonTransformable { }

extension PKDateTransform {
    
    private static func transformISO8601Date(dateStr: String) -> Date? {
        return fsFormatter.date(from: dateStr) ?? formatter.date(from: dateStr)
    }
    
    static func _transform(from object: Any) -> Date? {
        
        switch object {
        case let str as String:
            
            
            guard let date = transformISO8601Date(dateStr: str) else {
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
