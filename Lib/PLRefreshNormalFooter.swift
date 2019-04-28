//
//  PLRefreshNormalFooter.swift
//  PLKit
//
//  Created by iOS on 2019/4/28.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class PLRefreshNormalFooter: UIView {

    var gradualAlpa = false {
        didSet {
            if gradualAlpa {
                self.alpha = 0
            }
        }
    }
    
    var handleCallback: PLRefreshHandleCallback?
    init(callback: PLRefreshHandleCallback?) {
        super.init(frame: .init(x: 0, y: 0, width: 0, height: 64))
        self.backgroundColor = .red
        self.handleCallback = callback
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func refreshProgress(_ progress: CGFloat) {
        if self.gradualAlpa {
            self.alpha = progress
        }
    }
    
    func beginRefreshing() {
        if self.gradualAlpa {
            self.alpha = 1
        }
    }
    
    func endRefreshing() {
        UIView.animate(withDuration: 0.25, animations: {
            if self.gradualAlpa {
                self.alpha = 0
            }
        })
    }

}
