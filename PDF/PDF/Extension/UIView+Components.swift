//
//  UIView+Components.swift
//  MyBox
//
//  Created by dong chang on 2023/6/8.
//  Copyright © 2023 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import UIKit
extension UIView {
    private static let padding: CGFloat = 0
    func addScrollView() -> UIScrollView {
        let scrollView = UIScrollView(frame: self.bounds)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)

        scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        return scrollView
    }
}
