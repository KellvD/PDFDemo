//
//  UIView+extension.swift
//  MyBox
//
//  Created by changdong  on 2020/7/3.
//  Copyright © 2020 changdong. 2012-2019. All rights reserved.
//

import UIKit
public enum Direction: Int {
    case vertical
    case horizontal
}
extension UIView {

    /**
     添加翻页动画
     */
    func transition(subtype: CATransitionSubtype, duration: CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = duration
        animation.type = .push
        animation.subtype = subtype
        layer.add(animation, forKey: nil)
    }

    /**
     View添加圆角
     corners:圆角的方位，多个用[,]
     size:圆角的尺寸
     */
    func addRadius(corners: UIRectCorner, size: CGSize) {
        self.layoutIfNeeded()
        self.setNeedsLayout()
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: size)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }

    /*
     *View添加渐变背景
     *colors:渐变色
     *locations:色差分隔点
     *direction:渐变方向
     */

    func addBackgroundGradient(colors: [CGColor],
                               locations: [NSNumber],
                               startPoint: CGPoint,
                               endPoint:CGPoint) {
        let layer = CAGradientLayer()
        layer.colors = colors
        layer.locations = locations
        layer.startPoint = startPoint
        layer.endPoint = endPoint

        layer.frame = self.bounds
        self.layer.insertSublayer(layer, at: 0)
    }

    /*
     *View增加边框
     *color:边框颜色
     *width:边框宽度
     *edge:边框位置
     */
    func addBorder(color: UIColor, width: CGFloat, edge: UIRectEdge) {
        if edge == .all {
            self.layer.borderColor = color.cgColor
            self.layer.borderWidth = width
        } else {
            let layer = CALayer()
            layer.backgroundColor = color.cgColor
            let x = edge != .right ? 0 : self.frame.width - width
            let y = edge != .bottom ? 0 : self.frame.height - width
            layer.frame = CGRect(x: x, y: y, width: self.frame.width, height: self.frame.height)
            self.layer.addSublayer(layer)
        }
        self.layer.masksToBounds = true
    }

    /**
     *View 增加磨玻璃效果
     *style:样式
     */
    func addBlurEffect(style: UIBlurEffect.Style) {
        let effect = UIBlurEffect(style: style)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.frame = self.bounds
        self.backgroundColor = .clear
        self.addSubview(effectView)
        self.sendSubviewToBack(effectView)
    }

}
