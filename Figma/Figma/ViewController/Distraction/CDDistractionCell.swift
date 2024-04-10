//
//  CDDistractionCell.swift
//  Figma
//
//  Created by dong chang on 2024/1/13.
//

import UIKit

class CDDistractionCell: UITableViewCell {

    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var switchBtn: UISwitch!
    var actionBlock: ((Bool) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .baseBgColor

        self.titleLabel.textColor = .customBlack
        self.titleLabel.font = UIFont.medium(16)
        
        self.contentLabel.textColor = UIColor(94, 103, 117)
        self.contentLabel.font = UIFont.medium(12)
        self.switchBtn.onTintColor = UIColor(61, 138, 247)

    }

    @IBAction func switchAcction(_ sender: UISwitch) {
        guard let actionBlock = actionBlock else {
            return
        }
        actionBlock(sender.isOn)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
