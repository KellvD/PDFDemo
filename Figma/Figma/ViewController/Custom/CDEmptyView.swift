//
//  CDEmptyView.swift
//  Figma
//
//  Created by dong chang on 2024/1/13.
//

import UIKit

class CDEmptyView: UIView {
    enum EmptyType: Int {
        case ablum = 0
        case folder = 1
        case web = 2
    }
    private var iconView: UIImageView!
    private var titleLabel: UILabel!
    private var subLabel: UILabel!
    
    private let titleArr = ["Empty Album","Empty Folder","You’ll find your tabs here"]
    private let subArr = ["No media yet","No notes yet","Open tabs to visit different pages at the same time"]
    private let iconArr = ["Empty Folder","Empty Folder","暂无网页"]
    init(type: EmptyType) {
        let frame = CGRect(x: CDSCREEN_WIDTH/2.0 - 226/2.0, y: CDViewHeight/2.0 - 290/2.0, width: 226, height: 290)
        super.init(frame: frame)
        self.frame = frame
        
        iconView = UIImageView()
        addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.height.equalTo(201)
            make.width.equalTo(214)
            make.centerX.top.equalToSuperview()
        }
        
        titleLabel = UILabel()
        addSubview(titleLabel)
        titleLabel.backgroundColor = .white
        titleLabel.font = UIFont.medium(18)
        titleLabel.textColor = .customBlack
        titleLabel.textAlignment = .center
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconView.snp.bottom).offset(16)
            make.left.right.equalToSuperview()

        }

        subLabel = UILabel()
        subLabel.font = UIFont.regular(14)
        subLabel.numberOfLines = 0
        subLabel.textAlignment = .center
        subLabel.textColor = UIColor(187, 189, 195)
        addSubview(subLabel)
        subLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.left.right.equalToSuperview()

        }
        
        if type == .web {
            var rect = self.frame
            rect.origin.y += 112
            self.frame = rect
        }
        titleLabel.text = titleArr[type.rawValue]
        subLabel.text = subArr[type.rawValue]
        iconView.image = iconArr[type.rawValue].image
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
