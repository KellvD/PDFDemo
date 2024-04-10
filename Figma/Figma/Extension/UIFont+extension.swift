//
//  UIFont+extension.swift
//  MyBox
//
//  Created by changdong on 2021/3/9.
//  Copyright © 2018 changdong. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    class func medium(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Medium", size: size)!
    }
    
    class func regular(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Regular", size: size)!

    }
    
    class func semiBold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-SemiBold", size: size)!

    }
    
}
