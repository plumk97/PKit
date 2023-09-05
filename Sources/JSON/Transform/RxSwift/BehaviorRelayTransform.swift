//
//  BehaviorRelayTransform.swift
//  
//
//  Created by Plumk on 2023/9/5.
//

#if canImport(RxRelay)
import Foundation
import RxRelay

extension BehaviorRelay: PKJsonTransformable {}
extension BehaviorRelay: _PKJsonTransformable {
    static func _transform(from object: Any) -> Self? {
        
        if let value = object as? Element {
            return .init(value: value)
        }
        
        if let cls = Element.self as? PKJson.Type, let jsonObject = object as? PKJsonObject {
            guard let value = cls.decode(jsonObject) as? Element else {
                return nil
            }
            
            return .init(value: value)
        }
        
        if let value = (Element.self as? PKJsonTransformable.Type)?._transform(from: object) as? Element {
            return .init(value: value)
        }
        
        return nil
    }
    
    func _plainValue() -> Any? {
        self.value
    }
}


extension BehaviorRelay: RxTransformable {

    func transform(from object: Any) {
        if let value = object as? Element {
            self.accept(value)
            return
        }
        
        if let cls = Element.self as? PKJson.Type, let jsonObject = object as? PKJsonObject {
            guard let value = cls.decode(jsonObject) as? Element else {
                return
            }
            self.accept(value)
        }
        
        if let value = (Element.self as? PKJsonTransformable.Type)?._transform(from: object) as? Element {
            self.accept(value)
        }
    }
    
    func plainValue() -> Any? {
        return self.value
    }
}

#endif
