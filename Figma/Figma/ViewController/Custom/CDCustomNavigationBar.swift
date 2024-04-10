//
//  CDCustomNavigationBar.swift
//  Figma
//
//  Created by dong chang on 2024/1/13.
//

import UIKit

class CDCustomNavigationBar: UIView {

    @IBOutlet weak var titleLabell: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var editBtn1: UIButton!
    var actionBlock: (() -> Void)?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .white
        self.titleLabell.textColor = UIColor(36, 43, 56)
        self.titleLabell.font = UIFont.semiBold(28)
        
        self.timeLabel.textColor = UIColor(36, 43, 56)
        self.timeLabel.font = UIFont.regular(18)
        self.timeLabel.alpha = 0.5

    }
    
    func loadData(title:String, subTitle: String, image: String, handler: @escaping ()->Void) {
        titleLabell.text = title
        actionBlock = handler
        
        if title == "Settings" {
            timeLabel.isHidden = true
            editBtn1.isHidden = true
            
        } else {
            editBtn1.isHidden = false
            editBtn1.setImage(image.image, for: .normal)
            timeLabel.isHidden = false
            timeLabel.text = subTitle
        }
        
    }
    
    @IBAction func onClickItemAction(_ sender: UIButton) {
        guard let actionBlock = actionBlock else {
            return
        }
        actionBlock()
    }
}
