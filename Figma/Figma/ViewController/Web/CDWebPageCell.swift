//
//  CDWebPageCell.swift
//  Figma
//
//  Created by dong chang on 2024/1/13.
//

import UIKit
import WebKit

class CDWebPageCell: UICollectionViewCell {

    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var titleLabell: UILabel!
    @IBOutlet weak var thumbVView: UIImageView!
    
    @IBOutlet weak var closeIcon: UIButton!
    var actionBlock: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor(209, 209, 209)
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(209, 209, 209).cgColor
        self.titleLabell.textColor = .customBlack
        self.titleLabell.font = UIFont.regular(12)
        self.thumbVView.isUserInteractionEnabled = false
    }
    
    func loadData(file: CDWebPageInfo, isBatchEdit: Bool) {
        if isBatchEdit {
            self.closeIcon.setImage(file.isSelected == .yes ? "web_select_done".image : "web_select_normal".image, for: .normal)
        } else {
            self.closeIcon.setImage("关闭".image, for: .normal)
        }
        self.iconView.image = "历史记录图标".image

        self.titleLabell.text = file.webUrl        
        let image = UIImage(contentsOfFile: file.thumbImagePath.absolutePath)
        self.thumbVView.image = image
        self.thumbVView.contentMode = .scaleAspectFill
        
        if let url = URL(string: file.iconImagePath) {
            DispatchQueue.global().async {
                do {
                    let data = try Data(contentsOf: url)
                    DispatchQueue.main.async {
                        self.iconView.image = UIImage(data: data)
                    }
                } catch {
                    
                }
            }
        }
       
    }
    
    
    func reloadSelectImageView() {
        self.closeIcon.setImage(isSelected ? "web_select_done".image : "web_select_normal".image, for: .normal)
    }
    

    @IBAction func closePageAction(_ sender: Any) {
        guard let actionBlock = actionBlock else {
            return
        }
        actionBlock()
    }
}
