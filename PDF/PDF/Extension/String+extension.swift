//
//  String+extension.swift
//  MyBox
//
//  Created by changdong  on 2020/7/6.
//  Copyright © 2020 changdong. 2012-2019. All rights reserved.
//

import Foundation
import CommonCrypto
import UIKit
//import SwiftSoup

extension String {

    /// 根据图片名生成图片
    var image: UIImage? {
        if self.hasPrefix(String.RootPath()) { // 判断是否是沙盒文件
            if let image = UIImage(contentsOfFile: self) {
                return image
            } else {
                return nil
            }
        }

        return UIImage(named: self)
    }

    /// 截取字符串
    func subString(with range: NSRange) -> String {
        return self.AsNSString().substring(with: range)
    }
    func subString(location: Int, length: Int) -> String {
        return subString(with: NSRange(location: location, length: length))
    }
    func subString(to index: Int) -> String {
        return self.AsNSString().substring(to: index)
    }
    func subString(from index: Int) -> String {
        return self.AsNSString().substring(from: index)
    }
    
    /*
    去除字符串的空格
    */
    func removeSpaceAndNewline() -> String {
        let text = self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        return text
    }

    
    /// 根据文字适应label宽度
    /// - Parameters:
    ///   - width: label高度
    ///   - font: 文字font
    /// - Returns: label宽度
    func labelWidth(height: CGFloat, font: UIFont) -> CGFloat {
        let size: CGSize = CGSize(width: 0, height: height)
        let frame = self.boundingRect(with: size, options:
            NSStringDrawingOptions(rawValue: NSStringDrawingOptions.usesLineFragmentOrigin.rawValue |
                NSStringDrawingOptions.truncatesLastVisibleLine.rawValue |
                NSStringDrawingOptions.usesFontLeading.rawValue), attributes: [NSAttributedString.Key.font: font], context: nil)
        return frame.size.width
    }

    /// 根据文字适应label高度
    /// - Parameters:
    ///   - width: label宽度
    ///   - font: 文字font
    /// - Returns: label高度
    func labelHeight(width: CGFloat, font: UIFont) -> CGFloat {
        let size: CGSize = CGSize(width: width, height: 0)
        let frame = self.boundingRect(with: size, options:
            NSStringDrawingOptions(rawValue: NSStringDrawingOptions.usesLineFragmentOrigin.rawValue |
                NSStringDrawingOptions.truncatesLastVisibleLine.rawValue |
                NSStringDrawingOptions.usesFontLeading.rawValue), attributes: [NSAttributedString.Key.font: font], context: nil)
        return frame.size.height
    }

    
    /// 国际化
    func localize(_ comment: String = "") -> String {
        return String(format: NSLocalizedString(self, comment: ""), comment)
    }
}
