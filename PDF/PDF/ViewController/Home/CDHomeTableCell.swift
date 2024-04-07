//
//  CDHomeTableCell.swift
//  PDF
//
//  Created by dong chang on 2024/3/18.
//

import UIKit

class CDHomeTableCell: UICollectionViewCell {

    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var fileNameLabel: UILabel!
    
    @IBOutlet weak var folderNameLabel: UILabel!
    @IBOutlet weak var timelabel: UILabel!
    
    @IBOutlet weak var moreImV: UIImageView!
    var actionHandler: (()->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 12
        self.backgroundColor = .white

        fileNameLabel.textColor = .black
        fileNameLabel.font = .regular(16)
        
        timelabel.textColor = UIColor(0, 0, 0, 0.4)
        timelabel.font = .regular(10)
        
        
        folderNameLabel.textColor = .black
        folderNameLabel.font = .regular(16)
        moreImV.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(onMoreAction)))
    }

    func loadData(file: CDSafeFileInfo) {
        self.fileNameLabel.isHidden = file.type == .folder
        self.timelabel.isHidden = file.type == .folder
        self.folderNameLabel.isHidden = file.type != .folder

        if file.type == .file {
            self.fileNameLabel.text = file.name
            self.timelabel.text = GetTimeFormat(file.createTime)
        } else {
            self.folderNameLabel.text = file.name
        }
    }
    
    @objc func onMoreAction() {
        guard let actionHandler = actionHandler else {
            return
        }
        actionHandler()
    }
}
