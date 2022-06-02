//
//  PKOptionalTransfrom.swift
//
//  Created by Plumk on 2022/6/2.
//

import Foundation


extension Optional: PKTransfrom {
    static func transform(from object: Any) -> Optional<Wrapped>? {
        
        if let transform = Wrapped.self as? PKTransfrom.Type, let value = transform.transform(from: object) as? Wrapped {
            return .some(value)
        }
        return .none
    }
}
