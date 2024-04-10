//
//  CDPageVipCell.swift
//  Figma
//
//  Created by dong chang on 2024/3/29.
//

import UIKit

class CDPageVipCell: UICollectionViewCell {

    var actionHandler:(()->Void)?
    
    let arr = ["Photos & videos","important Filesimportant Files","Private multi browser","Remove all advertisements","Recover files you deleted in trash"]
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        self.backgroundColor = .white
        //
        let bottomTitleLabel = UILabel()
        self.addSubview(bottomTitleLabel)
        bottomTitleLabel.textColor = UIColor(red: 0.22, green: 0.22, blue: 0.227, alpha: 1)
        bottomTitleLabel.font = .regular(12)
        bottomTitleLabel.text = "Secured with iTunes. Cancel Anytime"
        bottomTitleLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-15)
            make.centerX.equalToSuperview().offset(23)
        }
        //
        let sl = UIImageView()
        sl.image = "Frame".image
        self.addSubview(sl)
        sl.snp.makeConstraints { make in
            make.right.equalTo(bottomTitleLabel.snp.left).offset(-5)
            make.centerY.equalTo(bottomTitleLabel)
            make.height.width.equalTo(18)
            
        }
        //
        let closeLabel = UIButton()
        self.addSubview(closeLabel)
        closeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(bottomTitleLabel.snp.top).offset(-20)
            make.centerX.equalToSuperview()
            make.height.equalTo(24)
        }
        closeLabel.titleLabel?.font = .regular(14)
        closeLabel.setTitleColor(UIColor(red: 0.733, green: 0.741, blue: 0.765, alpha: 1), for: .normal)
        let attributedString = NSMutableAttributedString(string: "proceed with limited version")
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
        // 应用属性字符串到按钮的attributedTitle
        closeLabel.setAttributedTitle(attributedString, for: .normal)
        closeLabel.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        //
        let str = "Only $4.99 per week or"
        let attr = NSMutableAttributedString(string: str)
        attr.addAttributes([.foregroundColor: UIColor(red: 0.129, green: 0.129, blue: 0.141, alpha: 1)], range: str.AsNSString().range(of: "Only $4.99 per week"))
        
        attr.addAttributes([.foregroundColor: UIColor(red: 0.733, green: 0.741, blue: 0.765, alpha: 1),.underlineStyle:NSUnderlineStyle.single.rawValue], range: str.AsNSString().range(of: "or"))
        
        let bottomContentLabel = UILabel()
        self.addSubview(bottomContentLabel)
        bottomContentLabel.snp.makeConstraints { make in
            make.bottom.equalTo(closeLabel.snp.top).offset(-4)
            make.centerX.equalToSuperview()
        }
        bottomContentLabel.textColor = UIColor(red: 0.129, green: 0.129, blue: 0.141, alpha: 1)
        bottomContentLabel.font = .regular(16)
        bottomContentLabel.attributedText = attr
        //
        let bottomTiplabel = UILabel()
        self.addSubview(bottomTiplabel)
        bottomTiplabel.snp.makeConstraints { make in
            make.bottom.equalTo(bottomContentLabel.snp.top).offset(-4)
            make.centerX.equalToSuperview()
            make.height.equalTo(34)
        }
        bottomTiplabel.text = "Unlimited Usage"
        bottomTiplabel.textColor = UIColor(red: 0.22, green: 0.22, blue: 0.227, alpha: 1)
        bottomTiplabel.font = .medium(22)
        

        let baseView1 = UIView()
        self.addSubview(baseView1)
        baseView1.snp.makeConstraints { make in
            
            make.bottom.equalTo(bottomTiplabel.snp.top).offset(-14)
            make.top.left.right.equalToSuperview()
        }
        baseView1.layoutIfNeeded()
        baseView1.setNeedsLayout()
        baseView1.addBackgroundGradient(colors: [
            UIColor(red: 0.892, green: 0.922, blue: 1, alpha: 1).cgColor,
            UIColor(red: 0.947, green: 0.955, blue: 0.975, alpha: 1).cgColor
        ], locations: [0, 1],startPoint: CGPoint(x: 0.25, y: 0.5), endPoint: CGPoint(x: 0.75, y: 0.5))
        baseView1.addRadius(corners: [.bottomRight,.bottomLeft], size: CGSize(width: 32, height: 32))
        
        let imageV = UIImageView(frame: CGRect(x: (self.width - 80)/2.0, y: 22, width: 80, height: 80))
        imageV.image = "image 203".image
        baseView1.addSubview(imageV)
        

        let titleLabel = UILabel(frame: CGRect(x: 40, y: imageV.maxY + 14 , width: baseView1.width - 40 * 2, height: 28))
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.text = "Maximum Security"
        titleLabel.textColor = UIColor(red: 0.22, green: 0.22, blue: 0.227, alpha: 1)
        titleLabel.font = .medium(22)
        baseView1.addSubview(titleLabel)
        
        let topContentLabel = UILabel(frame: CGRect(x: 32, y: titleLabel.maxY + 14 , width: baseView1.width - 32 * 2, height: 44))
        topContentLabel.textAlignment = .center
        topContentLabel.numberOfLines = 0
        topContentLabel.textColor = UIColor(red: 0.129, green: 0.129, blue: 0.141, alpha: 1)
        topContentLabel.font = .regular(14)
        topContentLabel.text = "Unlock all features with no ads & anylimits on all of your devices"
        baseView1.addSubview(topContentLabel)

        
        let height = baseView1.height - 20 - (topContentLabel.maxY + 20)
        let optionView = UIView(frame: CGRect(x: 16, y: topContentLabel.maxY + 20, width: self.width - 32, height: height))
        optionView.layer.cornerRadius = 12
        optionView.backgroundColor = .white
        baseView1.addSubview(optionView)
        let space:CGFloat = height / CGFloat(arr.count)

        for i in 0..<arr.count {
            
            let la = UILabel(frame: CGRect(x: 16, y: space * CGFloat(i), width: optionView.width - 40 * 2, height: CGFloat(space - 1)))
            la.textColor = UIColor(red: 0.129, green: 0.129, blue: 0.141, alpha: 1)
            la.text = arr[i]
            la.font = .regular(16)
            optionView.addSubview(la)
            
            if i < arr.count - 1 {
                let line = UIView(frame: CGRect(x: 16, y: la.maxY, width: optionView.width - 32, height: 1))
                line.backgroundColor = UIColor(red: 0.965, green: 0.965, blue: 0.965, alpha: 1)
                optionView.addSubview(line)
            }
            
            if i == 0 {
                let la = UILabel(frame: CGRect(x: optionView.width - 16 - 100, y: 0 , width: 100, height: CGFloat(space - 1)))
                la.text = "Unlimited"
                la.textColor = UIColor(red: 0.239, green: 0.541, blue: 0.969, alpha: 1)
                la.textAlignment = .right
                la.font = .regular(16)
                optionView.addSubview(la)
            } else {
                
                let sl = UIImageView(frame: CGRect(x: optionView.width - 16 - 18, y: la.midY - 9, width: 18, height: 18))
                sl.image = "全部选中".image
                optionView.addSubview(sl)
            }

        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func closeAction() {
        guard let actionHandler = actionHandler else {
            return
        }
        actionHandler()
    }
}
