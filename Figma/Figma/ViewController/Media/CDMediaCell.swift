//
//  CDMediaCell.swift
//  Figma
//
//  Created by dong chang on 2024/1/12.
//

import UIKit

class CDMediaCell: UICollectionViewCell {

    @IBOutlet weak var thumbView: UIImageView!
    
    @IBOutlet weak var playView: UIImageView!
    
    @IBOutlet weak var selectView: UIImageView!
    
    @IBOutlet weak var heartView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func loadData(file: CDSafeFileInfo, isBatchEdit: Bool) {
        self.selectView.isHidden = !isBatchEdit
        self.selectView.image = file.isSelected == .yes ? "select".image : "select-normal".image
        thumbView.isHidden = true
        
        self.playView.isHidden = !(file.fileType == .VideoType)
        self.heartView.isHidden = !(file.grade == .lovely)
        self.backgroundView = UIImageView(image: file.thumbImagePath.absolutePath.image)
    }
    
    
    func reloadSelectImageView() {
        self.selectView.image = isSelected ? "select".image : "select-normal".image
    }
}
