//
//  PLKit.swift
//  PLKit
//
//  Created by iOS on 2019/4/23.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

struct PL<Base> {
    let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
}

extension NSObjectProtocol where Self: UIView {
    
    var pl: PL<Self> {
        return PL(self)
    }
}

extension NSObjectProtocol where Self: UIViewController {
    
    var pl: PL<Self> {
        return PL(self)
    }
}
