//
//  PKCollectionTransfrom.swift
//
//  Created by Plumk on 2022/6/2.
//

import Foundation

extension Collection {
    
    static func collectionTransform(from object: Any) -> [Element]? {
        guard let arr = object as? [Any] else {
            return nil
        }
        
        var result = [Element]()
        
        arr.forEach({
            
            if let value = $0 as? Element {
                result.append(value)
            } else if let transform = Element.self as? PKTransfrom.Type, let value = transform.transform(from: $0) as? Element {
                result.append(value)
            }
        })
        
        return result
    }
}

extension Array: PKTransfrom {
    static func transform(from object: Any) -> Array<Element>? {
        return collectionTransform(from: object)
    }
}

extension Set: PKTransfrom {
    static func transform(from object: Any) -> Set<Element>? {
        guard let arr = collectionTransform(from: object) else {
            return nil
        }
        return Set(arr)
    }
}
