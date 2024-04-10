//
//  WebHistoryHeader.swift
//  Figma
//
//  Created by dong chang on 2024/1/15.
//

import UIKit

class WebHistoryHeader: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = .white
        self.titleLabel.textColor = .customBlack
        self.titleLabel.font = UIFont.semiBold(14)

        
        self.subLabel.textColor = UIColor(33, 33, 36)
        self.subLabel.font = UIFont.medium(10)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
