//
//  PKTransfrom.swift
//
//  Created by Plumk on 2022/6/2.
//

import Foundation

protocol PKTransfrom {
    static func transform(from object: Any) -> Self?
}
