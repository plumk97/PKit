//
//  PKMIMEType.swift
//  PKit
//
//  Created by Plumk on 2021/12/16.
//  Copyright © 2021 Plumk. All rights reserved.
//

import Foundation
#if SWIFT_PACKAGE
import PKCore
#endif

public class PKMIMEType {
    
    private static let shared = PKMIMEType()
    
    private var mimetypeMapping = [String: String]()
    
    private init() {
        
        self.readMIMETypeMapping()
    }
    
    /// 读取MIME 类型映射
    private func readMIMETypeMapping() {
        
        #if SWIFT_PACKAGE
        let bundle = Bundle.module
        #else
        guard let bundle = PKResourceBundle.current() else {
            return
        }
        #endif
        
        
        guard let path = bundle.path(forResource: "mimetype_mapping", ofType: "json") else {
            return
        }
        
        do {
            let data = try Data.init(contentsOf: .init(fileURLWithPath: path))
            guard let obj = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: String] else {
                return
            }
            
            self.mimetypeMapping = obj
            
        } catch {
            PKLog.log(error)
        }
    }
    
    public static func createMIMEType(fileExtension: String) -> String {
        return self.shared.mimetypeMapping[fileExtension] ?? "*"
    }
}
