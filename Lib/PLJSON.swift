//
//  PLJSON.swift
//  PLKit
//
//  Created by mini2019 on 2020/10/12.
//  Copyright © 2020 Plumk. All rights reserved.
//

import Foundation

protocol PLJSON {
    init()
}

extension PLJSON {
    
    private func enumProprs(_ callback: (_ name: String, _ props: Property, _ isObjC: Bool) -> Void) {
        let m = Mirror(reflecting: self)
        for c in m.children {
            if let label = c.label, var pros = c.value as? Property {
                let name = String(label[label.index(label.startIndex, offsetBy: 1)...])
                
                var isObjC: Bool = false
                if let cls = type(of: self) as? AnyClass {
                    isObjC = class_getProperty(cls, name.cString(using: .utf8)!) != nil
                }
                
                pros.instance = self
                pros.isObjC = isObjC
                pros.name = name
                
                callback(name, pros, isObjC)
            }
        }
    }
    
    @discardableResult
    func update(from: [String: Any]?) -> Self {

        guard let dict = from else {
            return self
        }
        
        self.enumProprs { (name, props, isOjbC) in
            
            var p = props
            if isOjbC {
                (p.instance as? NSObject)?.willChangeValue(forKey: name)
            }
            
            p.value = dict[name]
            
            if isOjbC {
                (p.instance as? NSObject)?.didChangeValue(forKey: name)
            }
        }
        return self
    }
    
    static func deserialize(from: [String: Any]?) -> Self {

        let m = Self.init()
        m.update(from: from)
        return m
    }
}


fileprivate protocol Property {
    
    /// 该属性属于哪个类实例
    var instance: PLJSON? { get set }
    
    /// 属性名
    var name: String? { get set }
    
    /// 属性值
    var value: Any? { get set }
    
    /// 是否是OC类型
    var isObjC: Bool { get set }
}


@propertyWrapper
class JSON<T>: Property {
    
    fileprivate var instance: PLJSON?
    fileprivate var name: String?
    fileprivate var isObjC: Bool = false
    fileprivate var value: Any? {
        set {
            if let v = newValue as? T {
                self.wrappedValue = v
            } else if let v = self.wrappedValue as? PLJSON {
                v.update(from: newValue as? [String: Any])
            } else {
                /// 取不到Object类型 先外部传入
                if let o = self.modelType as? PLJSON.Type {
                    
                    switch newValue {
                    case let dict as [String: Any]:
                        if let v = o.deserialize(from: dict) as? T {
                            self.wrappedValue = v
                        }
                        
                    case let array as [[String: Any]]:
                        if let v = array.map({ o.deserialize(from: $0) }) as? T {
                            self.wrappedValue = v
                        }
                    default:
                        break
                    }
                }
            }
        }
        
        get { self.wrappedValue}
    }
    
    fileprivate var modelType: Any?
    
    var wrappedValue: T
    
    init(wrappedValue value: T, type: Any? = nil) {
        self.wrappedValue = value
        self.modelType = type
    }
}
