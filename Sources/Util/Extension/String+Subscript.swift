//
//  String+Subscript.swift
//
//  Created by Plumk on 2022/1/9.
//

import Foundation

// MARK: - String substring
public extension String {
    
    subscript<T: BinaryInteger>(i: T) -> Character {
        return self[self.index(self.startIndex, offsetBy: .init(i))]
    }
    
    subscript<T: BinaryInteger>(bounds: Range<T>) -> Substring {
        let start = self.index(self.startIndex, offsetBy: .init(bounds.lowerBound))
        let end = self.index(self.startIndex, offsetBy: .init(bounds.upperBound))
        return self[start ..< end]
    }
    
    subscript<T: BinaryInteger>(bounds: ClosedRange<T>) -> Substring {
        
        let start = self.index(self.startIndex, offsetBy: .init(bounds.lowerBound))
        let end = self.index(self.startIndex, offsetBy: .init(bounds.upperBound))
        return self[start ... end]
    }
    
    subscript<T: BinaryInteger>(bounds: PartialRangeFrom<T>) -> Substring {
        let start = self.index(self.startIndex, offsetBy: .init(bounds.lowerBound))
        return self[start...]
    }
    
    subscript<T: BinaryInteger>(bounds: PartialRangeThrough<T>) -> Substring {
        let end = self.index(self.startIndex, offsetBy: .init(bounds.upperBound))
        return self[...end]
    }
}
