//
//  WebHistoryCell.swift
//  Figma
//
//  Created by dong chang on 2024/1/15.
//

import UIKit

class WebHistoryCell: UITableViewCell {

    var iconView: UIImageView!
    var titleLabel: UILabel!
    var lineView: UIView!
    var subLabel: UILabel!
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        iconView = UIImageView()
        contentView.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(32)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(30)

        }
        
        titleLabel = UILabel(frame: .zero)
        titleLabel.textColor = .customBlack
        titleLabel.font = UIFont.medium(16)
        titleLabel.text = ""
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(12)
            make.right.equalToSuperview().offset(-32)
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(18)
        }
        
        lineView = UIView(frame: .zero)
        lineView.backgroundColor = UIColor(235, 235, 235)
        contentView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-1)
            make.height.equalTo(1)
        }
        
        subLabel = UILabel(frame: .zero)
        subLabel.textColor = UIColor(red: 0.129, green: 0.129, blue: 0.141, alpha: 1)
        subLabel.font = UIFont.medium(10)
        contentView.addSubview(subLabel)
        subLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.bottom.equalTo(lineView.snp.top).offset(-12)

        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadData(file: CDWebPageInfo, searchText: String? = nil) {
        
        self.iconView.image = "历史记录图标".image
        var host = ""
        if #available(iOS 16.0, *) {
            if let tmp = file.webUrl.stringUrl?.host() {
                host = tmp
            }
        } else {
            if let url = file.webUrl.stringUrl,
               let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false),
               let tmp = components.host{
                host = tmp
            }
        }
        
        if let searchText = searchText {
            
            if file.webUrl.contains(searchText) {
                let mutablAttributeStr = NSMutableAttributedString(string: file.webUrl)
                let dict: [NSAttributedString.Key: Any] = [
                    NSAttributedString.Key.foregroundColor: UIColor.systemBlue
                ]
                mutablAttributeStr.setAttributes(dict, range: file.webUrl.AsNSString().range(of: searchText))
                self.titleLabel.attributedText = mutablAttributeStr
            } else {
                self.titleLabel.text = file.webUrl
            }
            
            if host.contains(searchText) {
                let mutablAttributeStr = NSMutableAttributedString(string: host)
                let dict: [NSAttributedString.Key: Any] = [
                    NSAttributedString.Key.foregroundColor: UIColor.systemBlue
                ]
                mutablAttributeStr.setAttributes(dict, range: host.AsNSString().range(of: searchText))
                self.subLabel.attributedText = mutablAttributeStr
            } else {
                self.subLabel.text = host
            }
        } else {
            self.titleLabel.text = file.webUrl
            self.subLabel.text = host
        }


        
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
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
