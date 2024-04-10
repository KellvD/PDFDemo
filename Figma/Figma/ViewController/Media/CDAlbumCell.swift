//
//  CDAlbumCell.swift
//  Figma
//
//  Created by dong chang on 2024/1/11.
//

import UIKit

class CDAlbumCell: UICollectionViewCell {

    @IBOutlet weak var bgView: UIImageView!
    @IBOutlet weak var thumbView: UIImageView!
    
    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var zeroLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var deleteCountLabel: UILabel!
    
    var longTapHandler: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.zeroLabel.textColor = UIColor(181, 190, 202)
        self.nameLabel.textColor = UIColor(36, 43, 56)
        self.countLabel.textColor = UIColor(33, 33, 36)
        self.nameLabel.font = UIFont.medium(16)
        self.countLabel.font = UIFont.medium(16)
        self.zeroLabel.font = UIFont.regular(16)
        self.deleteCountLabel.textColor = .white
        self.deleteCountLabel.font = .regular(12)
        self.zeroLabel.isHidden = true
        self.bgView.layer.cornerRadius = 12
        self.thumbView.layer.cornerRadius = 8
        self.deleteCountLabel.isHidden = true
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(lonePress))
        longPress.minimumPressDuration = 2
        self.addGestureRecognizer(longPress)
    }

    @objc func lonePress() {
        guard let longTapHandler = longTapHandler else {
            return
        }
        heavy()
        longTapHandler()
    }

    
    func loadData(folder: CDSafeFolder) {

        self.nameLabel.text = folder.folderName
        self.countLabel.text = "(\(folder.count))"
        self.iconView.isHidden = folder.count > 0 && folder.folderStatus != .Delete
        if folder.folderStatus == .All {
            self.iconView.image = "File-normal".image
        } else  if folder.folderStatus == .Favourite {
            self.iconView.image = "Like-icon".image
        } else if folder.folderStatus == .Delete {
            self.iconView.image = "delete-icon".image
        } else {
            self.iconView.image = "File-normal".image
        }
        
        if folder.count == 0 {
            self.deleteCountLabel.isHidden = true
            self.bgView.image = "empty album bg".image
            self.thumbView.image = nil
        } else {
            if folder.folderStatus != .Delete {
                self.deleteCountLabel.isHidden = true
                let file = CDSqlManager.shared.queryOneFileForFolderCoverImage(with: folder)
                self.thumbView.image = file.thumbImagePath.absolutePath.image
            } else {
                let count = CDSqlManager.shared.queryAllUnReadDeleteFile(type: .Media)
                self.deleteCountLabel.isHidden = count == 0
                if count <= 99 {
                    self.deleteCountLabel.text = "\(count)"
                } else {
                    self.deleteCountLabel.text = "99+"
                }
                self.thumbView.image = nil
            }
        }
        
        
    }
    
    func heavy() {
        let gereate = UIImpactFeedbackGenerator(style: .heavy)
        gereate.prepare()
        gereate.impactOccurred()
    }
    
}
