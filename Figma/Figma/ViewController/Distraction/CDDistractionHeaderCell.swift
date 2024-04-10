//
//  CDDistractionHeaderCell.swift
//  Figma
//
//  Created by dong chang on 2024/1/13.
//

import UIKit

class CDDistractionHeaderCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBOutlet weak var settingBt: UIButton!
    var actionBlock: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .baseBgColor

        self.titleLabel.textColor = .white
        self.titleLabel.font = UIFont.semiBold(16)
        
        self.subTitleLabel.textColor = .white
        self.subTitleLabel.font = UIFont.regular(12)
        
        settingBt.backgroundColor = .white
        settingBt.setTitleColor(.red, for: .normal)
        settingBt.titleLabel?.font = UIFont.semiBold(16)
        settingBt.layer.cornerRadius = 21
        
    }

    @IBAction func onSettingAction(_ sender: Any) {
        guard let actionBlock = actionBlock else {
            return
        }
        actionBlock()
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
