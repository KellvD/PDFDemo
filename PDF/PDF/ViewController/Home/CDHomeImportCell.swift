//
//  CDHomeImportCell.swift
//  PDF
//
//  Created by dong chang on 2024/3/18.
//

import UIKit

class CDHomeImportCell: UICollectionViewCell {

   
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .white
        self.layer.cornerRadius = 12
        self.titleLabel.textColor = .black
        self.titleLabel.font = .regular(12)
    }

}
