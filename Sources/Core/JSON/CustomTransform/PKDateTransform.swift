//
//  PKDateTransform.swift
//
//  Created by Plumk on 2022/6/2.
//

import Foundation

public struct PKDateTransform: PKCusomTransformable {


    public let dateFormatter: DateFormatter

    public init(dateFormatter: DateFormatter) {
        self.dateFormatter = dateFormatter
    }

    public init(format: String) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = format
        self.init(dateFormatter: formatter)
    }
    
    public func transformFromJSON(_ value: Any?) -> Any? {
        if let dateString = value as? String {
            return dateFormatter.date(from: dateString)
        }
        return nil
    }

    public func transformToJSON(_ value: Any?) -> Any? {
        if let date = value as? Date {
            return dateFormatter.string(from: date)
        }
        return nil
    }
}
