//
//  CDPagesViewCell.swift
//  Figma
//
//  Created by dong chang on 2024/3/28.
//

import UIKit

class CDPagesViewCell: UICollectionViewCell {

    var imageview: UIImageView!
     var titleLabel: UILabel!
    var contentLabel: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        contentLabel = UILabel(frame: CGRect(x: 32, y: self.height - 52 - 10 , width: self.width - 32 * 2, height: 52))
        contentLabel.textAlignment = .center
        contentLabel.numberOfLines = 0
        contentLabel.textColor = UIColor(red: 0.733, green: 0.741, blue: 0.765, alpha: 1)
        contentLabel.font = .regular(16)
        self.addSubview(contentLabel)
        
        titleLabel = UILabel(frame: CGRect(x: 40, y: contentLabel.minY - 8 - 28 , width: self.width - 40 * 2, height: 28))
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor(red: 0.22, green: 0.22, blue: 0.227, alpha: 1)
        titleLabel.font = .medium(22)
        self.addSubview(titleLabel)
        
        let baseView = UIView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: titleLabel.minY - 49))
        baseView.addBackgroundGradient(colors: [
            UIColor(red: 0.892, green: 0.922, blue: 1, alpha: 1).cgColor,
            UIColor(red: 0.947, green: 0.955, blue: 0.975, alpha: 1).cgColor
        ], locations: [0, 1],startPoint: CGPoint(x: 0.25, y: 0.5), endPoint: CGPoint(x: 0.75, y: 0.5))
        baseView.addRadius(corners: [.bottomRight,.bottomLeft], size: CGSize(width: 32, height: 32))
        self.addSubview(baseView)
        
        imageview = UIImageView(frame: CGRect(x: 47, y: UIDevice.safeAreaTop(), width: baseView.width - 47 * 2.0, height: baseView.height - UIDevice.safeAreaTop()))
        baseView.addSubview(imageview)
        
       

        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
