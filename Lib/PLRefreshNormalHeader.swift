//
//  PLRefreshNormalHeader.swift
//  PLKit
//
//  Created by iOS on 2019/4/26.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class PLRefreshNormalHeader: UIView, PLRefreshWidgetable {
    
    var handleCallback: PLRefreshHandleCallback?
    init(callback: PLRefreshHandleCallback?) {
        super.init(frame: .init(x: 0, y: 0, width: 0, height: 44))
        self.backgroundColor = .red
        self.handleCallback = callback
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func refreshProgress(_ progress: CGFloat) {
        
    }
    
    func beginRefreshing() {
        
    }
    
    func endRefreshing() {
        
    }
}
