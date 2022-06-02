//
//  PKCusomTransformable.swift
//
//  Created by Plumk on 2022/6/2.
//

import Foundation

public protocol PKCusomTransformable {
    func transformFromJSON(_ value: Any?) -> Any?
    func transformToJSON(_ value: Any?) -> Any?
}
