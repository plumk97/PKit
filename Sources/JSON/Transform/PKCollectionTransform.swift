//
//  PKCollectionTransform.swift
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
            } else if let value = (Element.self as? PKJsonTransformable.Type)?._transform(from: $0) as? Element {
                result.append(value)
            } else if let value = (Element.self as? PKJson.Type)?.decode($0 as? PKJsonObject) as? Element {
                result.append(value)
            }
        })
        
        return result
    }
    
    func collectionPlainValue() -> [Any] {
        
        var values = [Any]()
        for obj in self {
            
            if let value = obj as? PKJson {
                values.append(value.toJson())
            } else if let value = (obj as? PKJsonTransformable)?._plainValue() {
                values.append(value)
            } else {
                values.append(obj)
            }
            
        }
        return values
    }
}

extension Array: PKJsonTransformable {}
extension Array: _PKJsonTransformable {
    static func _transform(from object: Any) -> Array<Element>? {
        return collectionTransform(from: object)
    }
    
    func _plainValue() -> Any? {
        return self.collectionPlainValue()
    }
}

extension Set: PKJsonTransformable {}
extension Set: _PKJsonTransformable {
    static func _transform(from object: Any) -> Set<Element>? {
        guard let arr = collectionTransform(from: object) else {
            return nil
        }
        return Set(arr)
    }
    
    func _plainValue() -> Any? {
        return self.collectionPlainValue()
    }
}
