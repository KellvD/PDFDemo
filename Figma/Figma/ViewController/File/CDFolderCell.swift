//
//  CDFolderCell.swift
//  Figma
//
//  Created by dong chang on 2024/1/11.
//

import UIKit

class CDFolderCell: UITableViewCell {

    var iconView: UIImageView!
    var titleLabel: UILabel!
    var sperateLine: UIView!
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .baseBgColor
        
        iconView = UIImageView(frame:.zero)
        self.contentView.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20 + 16)
            make.centerY.equalToSuperview()
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
        
        titleLabel = UILabel(frame: .zero)
        titleLabel.textColor = .customBlack
        titleLabel.font = UIFont.regular(16)
        titleLabel.text = "All Files"
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(12)
            make.centerY.equalToSuperview()
        }
        
        sperateLine = UIView(frame: .zero)
        sperateLine.backgroundColor = UIColor(225, 237, 255)
        contentView.addSubview(sperateLine)
        sperateLine.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(72)
            make.right.equalToSuperview().offset(-32)
            make.bottom.equalToSuperview().offset(-1)
            make.height.equalTo(1)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadData(_ folder: CDSafeFolder){
        titleLabel.text = folder.folderName
        if folder.folderStatus == .Delete {
            let count = CDSqlManager.shared.queryAllUnReadDeleteFile(type: .File)
            self.iconView.image = count > 0 ? "删除红色".image : "Folder Delete-icon".image
        } else {
            self.iconView.image = "File Folder-icon".image
        }
    }
    
}
