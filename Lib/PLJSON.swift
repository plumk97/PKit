//
//  PLJSON.swift
//  PLKit
//
//  Created by mini2019 on 2020/10/12.
//  Copyright © 2020 iOS. All rights reserved.
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

extension Optional {
    static func fasda() {
        print("123")
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
class JSONKey<T>: Property {
    
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
                // 可选类型
            }
        }
        
        get { self.wrappedValue}
    }
    
    var wrappedValue: T
    
    init(wrappedValue value: T) {
        self.wrappedValue = value
    }
    
    init(initialValue value: T) {
        self.wrappedValue = value
    }
}
