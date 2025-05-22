//
//  UIColor+Hex.swift
//  
//
//  Created by Plumk on 2024/9/18.
//

import UIKit

public extension UIColor {
    convenience init(r: Int, g: Int, b: Int, a: CGFloat = 1) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }
    
    convenience init(hex: String) {
        if hex.count <= 0 {
            self.init(red: 0, green: 0, blue: 0, alpha: 1)
            return
        }
        var str: String!
        if hex.hasPrefix("#") {
            str = String(hex[hex.index(hex.startIndex, offsetBy: 1) ..< hex.endIndex])
        } else if (hex.uppercased().hasPrefix("0X")) {
            str = String(hex[hex.index(hex.startIndex, offsetBy: 2) ..< hex.endIndex])
        } else {
            str = hex
        }
        
        while str.count < 6 {
            let last = str.last!
            str.append(last)
        }
        
        if str.count == 6 {
            str = "FF" + str
        } else if str.count == 7 {
            str = "0" + str
        } else if str.count > 8 {
            str = String(str[str.startIndex ..< str.index(str.startIndex, offsetBy: 8)])
        }
    
        var value: UInt32 = 0
        if Scanner.init(string: str).scanHexInt32(&value) {
         
            let a = Int(value & 0xFF000000) >> 24
            let r = Int(value & 0x00FF0000) >> 16
            let g = Int(value & 0x0000FF00) >> 8
            let b = Int(value & 0x000000FF)
            self.init(r: r, g: g, b: b, a: CGFloat(a) / 255.0)
            return
        }
        self.init()
    }
}
