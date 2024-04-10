//
//  CDFilesCell.swift
//  Figma
//
//  Created by dong chang on 2024/1/14.
//

import UIKit

class CDFilesCell: UITableViewCell {
     var titleLabel: UILabel!
     var contentLabel: UILabel!
     var clockLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Initialization code
        titleLabel = UILabel(frame: .zero)
        titleLabel.textColor = .customBlack
        titleLabel.font = UIFont.medium(16)
        titleLabel.text = ""
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.top.equalToSuperview().offset(12)
        }
        
        let sperateLine = UIView(frame: .zero)
        sperateLine.backgroundColor = UIColor(250, 250, 250)
        contentView.addSubview(sperateLine)
        sperateLine.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-34)
            make.height.equalTo(1)
        }
        
        contentLabel = UILabel(frame: .zero)
        contentLabel.textColor = UIColor(119, 126, 135)
        contentLabel.font = UIFont.regular(12)
        contentLabel.numberOfLines = 2
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.bottom.equalTo(sperateLine.snp.top).offset(-16)
        }
        
        let clockView = UIImageView(frame:.zero)
        clockView.image = "clock".image
        self.contentView.addSubview(clockView)
        clockView.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(sperateLine.snp.bottom).offset(9)
            make.width.equalTo(16)
            make.height.equalTo(16)
        }
        
        clockLabel = UILabel(frame: .zero)
        clockLabel.textColor = UIColor(191, 197, 206)
        clockLabel.font = UIFont.regular(12)
        contentView.addSubview(clockLabel)
        clockLabel.text = ""
        clockLabel.snp.makeConstraints { make in
            make.centerY.equalTo(clockView)
            make.left.equalTo(clockView.snp.right).offset(4)
        }
        
        let detailView = UIImageView(frame:.zero)
        detailView.image = "detail".image
        self.contentView.addSubview(detailView)
        detailView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-32)
            make.centerY.equalTo(clockView)
            make.width.equalTo(16)
            make.height.equalTo(5)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadData(_ file: CDSafeFileInfo, searchText: String? = nil) {
        if let searchText = searchText {
            let mutablAttributeStr = NSMutableAttributedString(string: file.fileName)
            let dict: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.foregroundColor: UIColor.systemBlue
            ]
            mutablAttributeStr.setAttributes(dict, range: file.fileName.AsNSString().range(of: searchText))
            self.titleLabel.attributedText = mutablAttributeStr
        } else {
            self.titleLabel.text = file.fileName

        }
        self.clockLabel.text = GetTimeFormat(file.createTime)
        guard let content = try? String(contentsOfFile: file.filePath.absolutePath) else {
            self.contentLabel.isHidden = true
            return
        }
        self.contentLabel.isHidden = false

        self.contentLabel.text = content

    }

}
