//
//  CDWebSiteCell.swift
//  Figma
//
//  Created by dong chang on 2024/1/13.
//

import UIKit

class CDWebSiteCell: UICollectionViewCell {

    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor(241, 245, 250)
        self.layer.cornerRadius = 12
        self.titleLabel.textColor = .customBlack
        self.titleLabel.font = UIFont.regular(12)
        
    }
    
    func loadData(_ web: CDWebPageInfo) {
        self.titleLabel.text = web.webName
        self.iconView.image = web.iconImagePath.image
    }

}
