//
//  CDGuidedPaymentView.swift
//  Figma
//
//  Created by dong chang on 2024/3/3.
//

import UIKit

class Guideview: UIImageView {
    @IBOutlet weak var detailTipLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var detailContentLabel: UILabel!
    var actionHandler: ((Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.image = "背景".image
        titleLabel.textColor = UIColor(7, 55, 76)
        titleLabel.font = .semiBold(14)

        detailTipLabel.textColor = UIColor(127, 176, 202)
        detailTipLabel.font = .medium(12)
        
        detailContentLabel.textColor = UIColor(127, 176, 202)
        detailContentLabel.font = .medium(11)
        
        lineView.backgroundColor = UIColor(7, 55, 76)
    }
}

class CDGuidedPaymentView: UIView {

    var actionHandler: (() -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        let backGroundView = UIView(frame: frame)
        backGroundView.alpha = 0.6
        addSubview(backGroundView)

        // 毛玻璃效果
        let blurEffect = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.frame = backGroundView.bounds
        backGroundView.addSubview(effectView)

        
        let unlocktn = UIButton(type: .custom)
        unlocktn.setImage("video_icon".image, for: .normal)
        unlocktn.setBackgroundImage("按钮渐变".image, for: .normal)
        unlocktn.setTitle("Unlock access", for: .normal)
        unlocktn.titleLabel?.font = .medium(16)
        unlocktn.setTitleColor(.white, for: .normal)
        unlocktn.addTarget(self, action: #selector(actionUnlock), for: .touchUpInside)
        self.addSubview(unlocktn)

        unlocktn.snp.makeConstraints { make in
            make.width.equalTo(238)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-207)
            make.centerX.equalToSuperview()
        }
    
        
        let guaideView = UIImageView(image: "背景".image)
        self.addSubview(guaideView)
        guaideView.snp.makeConstraints { make in
            make.bottom.equalTo(unlocktn.snp.top).offset(-18)
            make.left.equalToSuperview().offset(70)
            make.right.equalToSuperview().offset(-70)
            make.height.equalTo(340)
        }
        
       let detailContentLabel = UILabel(frame: .zero)
        detailContentLabel.text = "Unlock more capabilities by watching sponsored content!"
        detailContentLabel.numberOfLines = 0
        guaideView.addSubview(detailContentLabel)
        detailContentLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.bottom.equalToSuperview().offset(-7)
        }
        
        let detailTipLabel = UILabel(frame: .zero)
        detailTipLabel.text = "Get all access"
        guaideView.addSubview(detailTipLabel)
        detailTipLabel.snp.makeConstraints { make in
            make.left.right.equalTo(detailContentLabel)
            make.bottom.equalTo(detailContentLabel.snp.top).offset(-7)
         }
        
        let titleLabel = UILabel(frame: .zero)
        titleLabel.text = "Get all access"
        guaideView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(47)
         }
        
        let lineView = UIView()
        guaideView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(3)
            make.left.equalTo(titleLabel.snp.left).offset(2)
            make.right.equalTo(titleLabel.snp.right).offset(2)
            make.height.equalTo(1)
         }
        
        titleLabel.textColor = UIColor(7, 55, 76)
        titleLabel.font = .semiBold(14)

        detailTipLabel.textColor = UIColor(127, 176, 202)
        detailTipLabel.font = .medium(12)
        
        detailContentLabel.textColor = UIColor(127, 176, 202)
        detailContentLabel.font = .medium(11)
        
        lineView.backgroundColor = UIColor(7, 55, 76)
        
        let left40094 = UIImageView(image: "Rectangle 40094".image)
        guaideView.addSubview(left40094)
        left40094.snp.makeConstraints { make in
            make.width.height.equalTo(97)
            make.left.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().offset(-97)
        }
        
        let right = UIImageView(image: "Rectangle 40095".image)
        guaideView.addSubview(right)
        right.snp.makeConstraints { make in
            make.width.height.equalTo(97)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-97)
        }
        
        let middle = UIImageView(image: "Rectangle 40093".image)
        guaideView.addSubview(middle)
        middle.snp.makeConstraints { make in
            make.width.height.equalTo(132)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-93)
        }
        
        let image199 = UIImageView(image: "image 199".image)
        middle.addSubview(image199)
        image199.snp.makeConstraints { make in
            make.bottom.equalTo(middle.snp.bottom).offset(-15)
            make.centerX.equalToSuperview().offset(-10)
            make.width.height.equalTo(34)
        }
        
        let image196 = UIImageView(image: "image 196".image)
        guaideView.addSubview(image196)
        image196.snp.makeConstraints { make in
            make.right.equalTo(middle.snp.right).offset(26)
            make.width.height.equalTo(82)
            make.bottom.equalTo(middle.snp.bottom).offset(15)

        }
        
        let ellipse862 = UIImageView(image: "Ellipse 862".image)
        guaideView.addSubview(ellipse862)
        ellipse862.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(27)
            make.right.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-70)
            make.top.equalToSuperview().offset(122)
        }
        
        
        let canceltn = UIButton(type: .custom)
        canceltn.setImage("激励关闭".image, for: .normal)
        canceltn.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        self.addSubview(canceltn)
        canceltn.snp.makeConstraints { make in
            make.width.equalTo(22)
            make.height.equalTo(22)
            make.left.equalTo(guaideView.snp.right).offset(-11)
            make.bottom.equalTo(guaideView.snp.top).offset(-8)
        }
        
        let lineview = UIImageView(image: "蝴蝶结条".image)
        self.addSubview(lineview)
        lineview.snp.makeConstraints { make in
            make.bottom.equalTo(guaideView.snp.top).offset(21)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.width.equalTo(37)
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func actionUnlock() {
        guard let actionHandler = self.actionHandler else {return}
        dismiss()
        actionHandler()
    }
    
    func showPopView() {
        DispatchQueue.main.async {
            self.isHidden = false

            UIView.animate(withDuration: 0.25, animations: {
                self.minY = 0
            }) { (_) in}
        }
    }
    
    @objc func dismiss() {

        UIView.animate(withDuration: 0.25, animations: {
            self.minY = self.height

        }) { (_) in
            self.isHidden = true
        }
    }
}
