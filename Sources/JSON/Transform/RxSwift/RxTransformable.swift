//
//  RxTransformable.swift
//  
//
//  Created by Plumk on 2023/9/5.
//

import Foundation

protocol RxTransformable {
    func transform(from object: Any)
    func plainValue() -> Any?
}
