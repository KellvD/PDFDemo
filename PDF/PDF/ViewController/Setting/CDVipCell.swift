//
//  CDVipCell.swift
//  PDF
//
//  Created by dong chang on 2024/3/23.
//

import UIKit

class CDVipCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var bgView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.backgroundColor = UIColor(0, 0, 0, 0)

        titleLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        titleLabel.font = .helvMedium(12)
        bgView.layer.cornerRadius = 8

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bgViewIsHidden(isHidden: Bool) {
        
        bgView.backgroundColor = isHidden ? UIColor(0, 0, 0, 0) : UIColor(red: 0.724, green: 0.265, blue: 0, alpha: 0.05)

    }
}
