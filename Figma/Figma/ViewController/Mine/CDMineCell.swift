//
//  CDMineCell.swift
//  Figma
//
//  Created by dong chang on 2024/1/13.
//

import UIKit

class CDMineCell: UITableViewCell {

    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var titlelabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .baseBgColor

        self.titlelabel.textColor = UIColor(51, 51, 51)
        self.titlelabel.font = UIFont.medium(16)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
