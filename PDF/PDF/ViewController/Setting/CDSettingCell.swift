//
//  CDSettingCell.swift
//  PDF
//
//  Created by dong chang on 2024/3/20.
//

import UIKit

class CDSettingCell: UITableViewCell {

    @IBOutlet weak var titleL: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .baseBgColor
        titleL.textColor = .black
        titleL.font = .helvBold(16)
        titleL.layer.cornerRadius = 28
        titleL.clipsToBounds = true
        titleL.backgroundColor = .white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
