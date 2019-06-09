//
//  PLPageTableView.swift
//  PLKit
//
//  Created by 李铁柱 on 2019/6/3.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

class PLPageTableView: UITableView, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
