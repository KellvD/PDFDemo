//
//  CDToolCell.swift
//  PDF
//
//  Created by dong chang on 2024/3/18.
//

import UIKit

class CDToolCell: UICollectionViewCell {

    @IBOutlet weak var titleLabell: UILabel!
    
    @IBOutlet weak var iconView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabell.textColor = .black
        titleLabell.font = .medium(12)
        self.layer.cornerRadius = 12
        self.backgroundColor = .white
    }
    
    func loadData(tool: CDToolOption) {
        titleLabell.text = tool.rawValue
        iconView.image = tool.rawValue.image
    }

}
