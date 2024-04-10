//
//  UIColor+extension.swift
//  MyBox
//
//  Created by changdong on 2020/12/21.
//  Copyright © 2019 changdong. All rights reserved.
//

import Foundation
import UIKit
extension UIColor {
    static var customBlack: UIColor {
        get {UIColor(33, 33, 36)}
    }
    
    static var baseBgColor: UIColor {
        get {UIColor(245, 245, 245)}
    }
}

extension UIColor {
    convenience init(_ Red: CGFloat, _ Green: CGFloat, _ Blue: CGFloat) {
        self.init(red: Red/255.0, green: Green/255.0, blue: Blue/255.0, alpha: 1.0)
    }

    convenience init(_ Red: CGFloat, _ Green: CGFloat, _ Blue: CGFloat, _ Alpha: CGFloat) {
        self.init(red: Red/255.0, green: Green/255.0, blue: Blue/255.0, alpha: Alpha)
    }

    convenience init(hexStr: String) {
        let hexNum = Int(hexStr, radix: 16)!
        self.init(red: CGFloat((hexNum & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((hexNum & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat((hexNum & 0x0000FF) >> 0) / 255.0,
                  alpha: 1.0)
    }
}


